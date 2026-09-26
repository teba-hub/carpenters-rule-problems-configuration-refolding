function [trajectory, f_history, info] = ...
        optimize_configuration_refolding(initial_poly, target_poly, options)
    %OPTIMIZE_CONFIGURATION_REFOLDING Minimize the refolding objective.
    %
    % Inputs:
    %   initial_poly - Initial polygon as an n-by-2 matrix.
    %   target_poly  - Target polygon as an n-by-2 matrix.
    %   options      - Solver options structure.
    %
    % Outputs:
    %   trajectory - Saved polygon states.
    %   f_history  - Objective values at every iteration.
    %   info       - Final solver information.

    if nargin < 3
        options = struct();
    end
    if ~isfield(options, 'c'), options.c = 1.0; end
    if ~isfield(options, 'dynamic_c'), options.dynamic_c = struct(); end
    if ~isfield(options.dynamic_c, 'enabled')
        options.dynamic_c.enabled = false;
    end
    if ~isfield(options.dynamic_c, 'trigger_distance_ratio')
        options.dynamic_c.trigger_distance_ratio = 0.20;
    end
    if ~isfield(options.dynamic_c, 'trigger_step_size')
        options.dynamic_c.trigger_step_size = 1e-3;
    end
    if ~isfield(options.dynamic_c, 'trigger_iterations')
        options.dynamic_c.trigger_iterations = 30;
    end
    if ~isfield(options.dynamic_c, 'reduction_factor')
        options.dynamic_c.reduction_factor = 0.30;
    end
    if ~isfield(options.dynamic_c, 'minimum_c')
        options.dynamic_c.minimum_c = 0.003;
    end
    if ~isfield(options.dynamic_c, 'reset_step_size')
        options.dynamic_c.reset_step_size = 0.01;
    end
    if ~isfield(options, 'step_size'), options.step_size = 0.1; end
    if ~isfield(options, 'line_search'), options.line_search = struct(); end
    if ~isfield(options.line_search, 'reduction_factor')
        options.line_search.reduction_factor = 0.5;
    end
    if ~isfield(options.line_search, 'growth_factor')
        options.line_search.growth_factor = 1.05;
    end
    if ~isfield(options.line_search, 'max_backtracks')
        options.line_search.max_backtracks = 30;
    end
    if ~isfield(options.line_search, 'minimum_step_size')
        options.line_search.minimum_step_size = 1e-8;
    end
    if ~isfield(options, 'max_iter'), options.max_iter = 1000; end
    if ~isfield(options, 'tolerance'), options.tolerance = 1e-6; end
    if ~isfield(options, 'stagnation_tolerance')
        options.stagnation_tolerance = 1e-10;
    end
    if ~isfield(options, 'stagnation_iterations')
        options.stagnation_iterations = 100;
    end
    if ~isfield(options, 'save_interval'), options.save_interval = 10; end
    if ~isfield(options, 'verbose'), options.verbose = true; end
    if ~isfield(options, 'realtime_plot'), options.realtime_plot = false; end
    if ~isfield(options, 'plot_interval'), options.plot_interval = 1; end
    if ~isfield(options, 'save_video'), options.save_video = false; end
    if ~isfield(options, 'video_filename')
        options.video_filename = 'configuration_refolding_realtime.mp4';
    end
    if ~isfield(options, 'video_fps'), options.video_fps = 30; end
    if ~isfield(options, 'plot_style'), options.plot_style = struct(); end
    options.plot_style = resolve_plot_style(options.plot_style);

    validateattributes(options.c, {'numeric'}, ...
                       {'scalar', 'real', 'finite', 'positive'});
    validateattributes(options.line_search.reduction_factor, {'numeric'}, ...
                       {'scalar', 'real', 'finite', '>', 0, '<', 1});
    validateattributes(options.line_search.growth_factor, {'numeric'}, ...
                       {'scalar', 'real', 'finite', '>', 1});
    validateattributes(options.line_search.max_backtracks, {'numeric'}, ...
                       {'scalar', 'integer', 'nonnegative'});
    validateattributes(options.line_search.minimum_step_size, {'numeric'}, ...
                       {'scalar', 'real', 'finite', 'positive'});
    if options.dynamic_c.enabled
        validateattributes(options.dynamic_c.trigger_distance_ratio, ...
                           {'numeric'}, ...
                           {'scalar', 'real', 'finite', 'positive'});
        validateattributes(options.dynamic_c.trigger_step_size, ...
                           {'numeric'}, ...
                           {'scalar', 'real', 'finite', 'positive'});
        validateattributes(options.dynamic_c.trigger_iterations, ...
                           {'numeric'}, ...
                           {'scalar', 'integer', 'positive'});
        validateattributes(options.dynamic_c.reduction_factor, ...
                           {'numeric'}, ...
                           {'scalar', 'real', 'finite', '>', 0, '<', 1});
        validateattributes(options.dynamic_c.minimum_c, {'numeric'}, ...
                           {'scalar', 'real', 'finite', 'positive', ...
                            '<=', options.c});
        validateattributes(options.dynamic_c.reset_step_size, {'numeric'}, ...
                           {'scalar', 'real', 'finite', 'positive'});
    end

    phi_target = configuration_contact_energy(target_poly);

    if options.verbose
        fprintf('========== Gradient Descent Started ==========\n');
        fprintf('Target cycle-linkage energy: Phi(p) = %.6f\n', phi_target);
        fprintf('Initial step size = %.6f\n', options.step_size);
        fprintf(['Backtracking line search: reduction %.3g, growth %.3g, ', ...
                 'minimum step %.1e\n'], ...
                options.line_search.reduction_factor, ...
                options.line_search.growth_factor, ...
                options.line_search.minimum_step_size);
        fprintf('Initial energy weight c = %.6f\n', options.c);
        if options.dynamic_c.enabled
            fprintf(['Dynamic c enabled: reduce by %.4g after %d small-step ', ...
                     'iterations at distance ratio <= %.2f\n'], ...
                    options.dynamic_c.reduction_factor, ...
                    options.dynamic_c.trigger_iterations, ...
                    options.dynamic_c.trigger_distance_ratio);
            fprintf('Minimum c = %.6f; reset step size = %.3e\n', ...
                    options.dynamic_c.minimum_c, ...
                    options.dynamic_c.reset_step_size);
        end
        fprintf('Gradient tolerance = %.2e\n', options.tolerance);
        fprintf(['Stagnation test = relative objective change <= %.2e ', ...
                 'for %d iterations\n\n'], ...
                options.stagnation_tolerance, ...
                options.stagnation_iterations);
    end

    current_poly = initial_poly;
    step_size = options.step_size;
    current_c = options.c;
    trajectory = {current_poly};
    f_history = [];
    c_history = current_c;
    stagnation_count = 0;
    dynamic_small_step_count = 0;
    dynamic_c_switches = 0;
    total_backtracks = 0;
    failed_line_searches = 0;

    info.converged = false;
    info.iterations = 0;
    info.termination_reason = 'maximum_iterations';

    [f_current, d_current, phi_current] = ...
        configuration_refolding_objective( ...
        current_poly, target_poly, phi_target, current_c);
    initial_distance = d_current;
    f_history(end+1) = f_current;

    if options.verbose
        fprintf('Initial state: f=%.6f, d=%.6f, Phi(x)=%.6f\n', ...
                f_current, d_current, phi_current);
    end

    video_writer = [];
    if options.realtime_plot
        fig_realtime = figure( ...
            'Name', ['Real-Time Configuration Refolding [Space: Pause/Resume, ', ...
                     'Left Arrow: Step Back, Esc: Stop]'], ...
            'Position', [100, 100, 1400, 600]);

        all_polys = [initial_poly; target_poly; current_poly];
        x_min = min(all_polys(:, 1)) - 1.5;
        x_max = max(all_polys(:, 1)) + 1.5;
        y_min = min(all_polys(:, 2)) - 1.5;
        y_max = max(all_polys(:, 2)) + 1.5;

        interact_state = struct();
        interact_state.paused = false;
        interact_state.step_back = false;
        interact_state.stop_requested = false;
        interact_state.display_index = 0;
        interact_state.saved_polys = {};
        interact_state.saved_f_values = [];
        interact_state.saved_iters = [];
        set(fig_realtime, 'UserData', interact_state);
        set(fig_realtime, 'KeyPressFcn', @keyPressCallback);

        if options.save_video
            video_writer = VideoWriter(options.video_filename, 'MPEG-4');
            video_writer.FrameRate = options.video_fps;
            open(video_writer);
            fprintf('Recording video: %s (%d fps)\n', ...
                    options.video_filename, options.video_fps);
        end
    end

    for iter = 1:options.max_iter
        if options.realtime_plot && isgraphics(fig_realtime)
            interact_state = get(fig_realtime, 'UserData');
            if interact_state.stop_requested
                if options.verbose
                    fprintf(['\nStop requested by the user. Optimization ', ...
                             'ended normally; output generation will continue.\n']);
                end
                info.iterations = iter - 1;
                info.termination_reason = 'user_requested';
                break;
            end
        end

        grad = configuration_refolding_gradient( ...
            current_poly, target_poly, phi_target, current_c);
        grad_norm = norm(grad, 'fro');

        if grad_norm < options.tolerance
            if options.verbose
                fprintf('\nConverged: gradient norm %.2e < %.2e\n', ...
                        grad_norm, options.tolerance);
            end
            info.converged = true;
            info.iterations = iter;
            info.termination_reason = 'gradient_tolerance';
            break;
        end

        if grad_norm > 0
            grad_direction = grad / grad_norm;
        else
            if options.verbose
                fprintf('\nThe gradient is zero. Iteration stopped.\n');
            end
            info.converged = true;
            info.iterations = iter;
            info.termination_reason = 'zero_gradient';
            break;
        end

        previous_f = f_current;
        c_changed = false;
        dynamic_c_exhausted = false;
        step_accepted = false;
        trial_step = max(step_size, ...
                         options.line_search.minimum_step_size);
        line_search_backtracks = 0;

        while line_search_backtracks <= ...
                options.line_search.max_backtracks
            poly_new = current_poly - trial_step * grad_direction;
            [f_new, d_new, phi_new] = ...
                configuration_refolding_objective( ...
                poly_new, target_poly, phi_target, current_c);

            if isfinite(f_new) && f_new < f_current
                current_poly = poly_new;
                f_current = f_new;
                d_current = d_new;
                phi_current = phi_new;
                step_size = trial_step * ...
                            options.line_search.growth_factor;
                step_accepted = true;
                break;
            end

            if line_search_backtracks == ...
                    options.line_search.max_backtracks || ...
                    trial_step <= options.line_search.minimum_step_size
                break;
            end

            trial_step = max( ...
                trial_step * options.line_search.reduction_factor, ...
                options.line_search.minimum_step_size);
            line_search_backtracks = line_search_backtracks + 1;
        end

        total_backtracks = total_backtracks + line_search_backtracks;
        if ~step_accepted
            step_size = trial_step;
            failed_line_searches = failed_line_searches + 1;
        end

        distance_ratio = d_current / max(initial_distance, eps);
        if options.dynamic_c.enabled && ...
                distance_ratio <= options.dynamic_c.trigger_distance_ratio && ...
                step_size <= options.dynamic_c.trigger_step_size
            dynamic_small_step_count = dynamic_small_step_count + 1;
        else
            dynamic_small_step_count = 0;
        end

        if options.dynamic_c.enabled && ...
                dynamic_small_step_count >= ...
                options.dynamic_c.trigger_iterations
            candidate_c = max(options.dynamic_c.minimum_c, ...
                              current_c * ...
                              options.dynamic_c.reduction_factor);

            if candidate_c < current_c * (1 - 10 * eps)
                previous_c = current_c;
                current_c = candidate_c;
                step_size = max(step_size, ...
                                options.dynamic_c.reset_step_size);
                [f_current, d_current, phi_current] = ...
                    configuration_refolding_objective( ...
                    current_poly, target_poly, phi_target, current_c);
                dynamic_c_switches = dynamic_c_switches + 1;
                dynamic_small_step_count = 0;
                stagnation_count = 0;
                c_changed = true;

                if options.verbose
                    fprintf(['\nDynamic c update at iteration %d: ', ...
                             'c %.6g -> %.6g, distance ratio %.3f, ', ...
                             'step reset to %.3e\n'], ...
                            iter, previous_c, current_c, ...
                            distance_ratio, step_size);
                end
            else
                dynamic_c_exhausted = true;
            end
        end

        if mod(iter, options.save_interval) == 0
            trajectory{end+1} = current_poly; %#ok<AGROW>
        end
        f_history(end+1) = f_current; %#ok<AGROW>
        c_history(end+1) = current_c; %#ok<AGROW>

        if c_changed
            relative_f_change = Inf;
        else
            relative_f_change = abs(previous_f - f_current) / ...
                                max([1, abs(previous_f), abs(f_current)]);
        end
        if isfinite(relative_f_change) && ...
                relative_f_change <= options.stagnation_tolerance
            stagnation_count = stagnation_count + 1;
        else
            stagnation_count = 0;
        end

        if options.verbose && mod(iter, 10) == 0
            fprintf(['Iter %4d: f=%.6f, d=%.6f, Phi=%.6f, c=%.6g, ', ...
                     '||grad||=%.2e, step=%.2e, backtracks=%d\n'], ...
                    iter, f_current, d_current, phi_current, current_c, ...
                    grad_norm, step_size, line_search_backtracks);
        end

        if options.realtime_plot && mod(iter, options.plot_interval) == 0
            interact_state = get(fig_realtime, 'UserData');
            interact_state.display_index = interact_state.display_index + 1;
            interact_state.saved_polys{interact_state.display_index} = current_poly;
            interact_state.saved_f_values(interact_state.display_index) = f_current;
            interact_state.saved_iters(interact_state.display_index) = iter;
            set(fig_realtime, 'UserData', interact_state);

            draw_current_state(fig_realtime, current_poly, f_history, iter, ...
                options.max_iter, x_min, x_max, y_min, y_max, ...
                options.plot_style);

            if options.save_video && ~isempty(video_writer)
                frame = getframe(fig_realtime);
                writeVideo(video_writer, frame);
            end

            interact_state = get(fig_realtime, 'UserData');
            while interact_state.paused || interact_state.step_back
                interact_state = get(fig_realtime, 'UserData');

                if interact_state.step_back
                    if interact_state.display_index > 1
                        interact_state.display_index = interact_state.display_index - 1;
                        interact_state.step_back = false;
                        set(fig_realtime, 'UserData', interact_state);

                        prev_poly = interact_state.saved_polys{interact_state.display_index};
                        prev_iter = interact_state.saved_iters(interact_state.display_index);
                        draw_current_state(fig_realtime, prev_poly, ...
                            f_history(1:prev_iter), prev_iter, options.max_iter, ...
                            x_min, x_max, y_min, y_max, options.plot_style);
                    else
                        interact_state.step_back = false;
                        set(fig_realtime, 'UserData', interact_state);
                    end
                end

                if interact_state.paused
                    pause(0.1);
                else
                    break;
                end
            end
        end

        if dynamic_c_exhausted
            if options.verbose
                fprintf(['\nStopped: dynamic c reached its minimum value ', ...
                         '(%.6g) and the small-step condition persisted.\n'], ...
                        current_c);
            end
            info.iterations = iter;
            info.termination_reason = 'dynamic_c_minimum_stalled';
            break;
        end

        if stagnation_count >= options.stagnation_iterations
            if options.verbose
                fprintf(['\nStopped: the relative objective change remained ', ...
                         'below %.2e for %d consecutive iterations.\n'], ...
                        options.stagnation_tolerance, ...
                        options.stagnation_iterations);
            end
            info.iterations = iter;
            info.termination_reason = 'objective_stagnation';
            break;
        end
    end

    if ~isequal(trajectory{end}, current_poly)
        trajectory{end+1} = current_poly;
    end

    if options.save_video && ~isempty(video_writer)
        close(video_writer);
        fprintf('Video saved: %s\n', options.video_filename);
    end

    if strcmp(info.termination_reason, 'maximum_iterations')
        if options.verbose
            fprintf('\nMaximum iteration count reached: %d\n', options.max_iter);
        end
        info.converged = false;
        info.iterations = options.max_iter;
    end

    info.final_f = f_current;
    info.final_d = d_current;
    info.final_phi = phi_current;
    info.final_step_size = step_size;
    info.final_c = current_c;
    info.c_switches = dynamic_c_switches;
    info.c_history = c_history;
    info.total_backtracks = total_backtracks;
    info.failed_line_searches = failed_line_searches;

    if options.verbose
        fprintf('\n========== Gradient Descent Finished ==========\n');
        fprintf('Total iterations: %d\n', info.iterations);
        fprintf('Termination reason: %s\n', info.termination_reason);
        fprintf('Final objective value: f = %.6f\n', info.final_f);
        fprintf('  Distance term: d = %.6f\n', info.final_d);
        fprintf('  Energy: Phi(x) = %.6f (target Phi(p) = %.6f)\n', ...
                info.final_phi, phi_target);
        fprintf('  Final energy weight: c = %.6g (%d dynamic updates)\n', ...
                info.final_c, info.c_switches);
        fprintf('  Backtracking reductions: %d; failed searches: %d\n', ...
                info.total_backtracks, info.failed_line_searches);
    end
end

function keyPressCallback(src, event)
    state = get(src, 'UserData');
    if strcmp(event.Key, 'space')
        state.paused = ~state.paused;
    elseif strcmp(event.Key, 'leftarrow')
        state.step_back = true;
    elseif strcmp(event.Key, 'escape')
        state.stop_requested = true;
        state.paused = false;
        state.step_back = false;
    end
    set(src, 'UserData', state);
end

function draw_current_state(fig, polygon, f_hist, current_iter, max_iter, ...
                            x_min, x_max, y_min, y_max, plot_style)
    figure(fig);
    clf;

    subplot('Position', [0.05, 0.1, 0.6, 0.85]);
    hold on;
    axis equal;
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    set(gca, 'Color', 'w');
    box on;

    x = [polygon(:, 1); polygon(1, 1)];
    y = [polygon(:, 2); polygon(1, 2)];
    plot(x, y, 'k-', 'LineWidth', plot_style.line_width);
    plot(polygon(:, 1), polygon(:, 2), 'ko', ...
         'MarkerSize', plot_style.marker_size, 'MarkerFaceColor', 'k');

    state = get(fig, 'UserData');
    if state.paused
        title(sprintf(['[Paused Cycle Linkage] Iteration %d/%d ', ...
                       '(Space: Resume, Left Arrow: Step Back, ', ...
                       'Esc: Stop)'], ...
                      current_iter, max_iter), ...
              'FontSize', 14, 'Color', 'r');
    else
        title(sprintf(['Cycle Linkage | Iteration %d/%d (Progress: %.1f%%) ', ...
                       '[Esc: Stop]'], ...
                      current_iter, max_iter, current_iter/max_iter*100), ...
              'FontSize', 14);
    end
    xlabel('X');
    ylabel('Y');

    subplot('Position', [0.72, 0.1, 0.25, 0.85]);
    plot(1:length(f_hist), f_hist, 'b-', 'LineWidth', 2);
    hold on;
    plot(current_iter, f_hist(current_iter), 'ro', ...
         'MarkerSize', 8, 'MarkerFaceColor', 'r');
    xlabel('Iteration', 'FontSize', 12);
    ylabel('Objective value f(x)', 'FontSize', 12);
    title(sprintf('Optimization Progress\nf=%.4f', f_hist(current_iter)), ...
          'FontSize', 12);
    grid on;

    drawnow;
end
