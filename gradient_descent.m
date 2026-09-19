function [trajectory, f_history, info] = gradient_descent(initial_poly, target_poly, options)
    %GRADIENT_DESCENT Minimize the refolding objective by gradient descent.
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
    if ~isfield(options, 'step_size'), options.step_size = 0.1; end
    if ~isfield(options, 'max_iter'), options.max_iter = 1000; end
    if ~isfield(options, 'tolerance'), options.tolerance = 1e-6; end
    if ~isfield(options, 'save_interval'), options.save_interval = 10; end
    if ~isfield(options, 'verbose'), options.verbose = true; end
    if ~isfield(options, 'realtime_plot'), options.realtime_plot = false; end
    if ~isfield(options, 'plot_interval'), options.plot_interval = 1; end
    if ~isfield(options, 'save_video'), options.save_video = false; end
    if ~isfield(options, 'video_filename'), options.video_filename = 'morphing.mp4'; end
    if ~isfield(options, 'video_fps'), options.video_fps = 30; end

    phi_target = compute_energy_phi(target_poly);

    if options.verbose
        fprintf('========== Gradient Descent Started ==========\n');
        fprintf('Target polygon energy: Phi(p) = %.6f\n', phi_target);
        fprintf('Initial step size = %.6f\n', options.step_size);
        fprintf('Energy weight c = %.6f\n\n', options.c);
    end

    current_poly = initial_poly;
    step_size = options.step_size;
    trajectory = {current_poly};
    f_history = [];

    [f_current, d_current, phi_current] = objective_function( ...
        current_poly, target_poly, phi_target, options.c);
    f_history(end+1) = f_current;

    if options.verbose
        fprintf('Initial state: f=%.6f, d=%.6f, Phi(x)=%.6f\n', ...
                f_current, d_current, phi_current);
    end

    video_writer = [];
    if options.realtime_plot
        fig_realtime = figure( ...
            'Name', 'Real-Time Refolding [Space: Pause/Resume, Left Arrow: Step Back]', ...
            'Position', [100, 100, 1400, 600]);

        all_polys = [initial_poly; target_poly; current_poly];
        x_min = min(all_polys(:, 1)) - 1.5;
        x_max = max(all_polys(:, 1)) + 1.5;
        y_min = min(all_polys(:, 2)) - 1.5;
        y_max = max(all_polys(:, 2)) + 1.5;

        interact_state = struct();
        interact_state.paused = false;
        interact_state.step_back = false;
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
        grad = compute_gradient(current_poly, target_poly, phi_target, options.c);
        grad_norm = norm(grad, 'fro');

        if grad_norm < options.tolerance
            if options.verbose
                fprintf('\nConverged: gradient norm %.2e < %.2e\n', ...
                        grad_norm, options.tolerance);
            end
            info.converged = true;
            info.iterations = iter;
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
            break;
        end

        poly_new = current_poly - step_size * grad_direction;
        [f_new, d_new, phi_new] = objective_function( ...
            poly_new, target_poly, phi_target, options.c);

        if f_new < f_current
            current_poly = poly_new;
            f_current = f_new;
            d_current = d_new;
            phi_current = phi_new;
            step_size = step_size * 1.05;
        else
            step_size = step_size * 0.5;
            poly_new = current_poly - step_size * grad_direction;

            [f_new, d_new, phi_new] = objective_function( ...
                poly_new, target_poly, phi_target, options.c);

            current_poly = poly_new;
            f_current = f_new;
            d_current = d_new;
            phi_current = phi_new;
        end

        if mod(iter, options.save_interval) == 0
            trajectory{end+1} = current_poly; %#ok<AGROW>
        end
        f_history(end+1) = f_current; %#ok<AGROW>

        if options.verbose && mod(iter, 10) == 0
            fprintf(['Iter %4d: f=%.6f, d=%.6f, Phi=%.6f, ', ...
                     '||grad||=%.2e, step=%.2e\n'], ...
                    iter, f_current, d_current, phi_current, grad_norm, step_size);
        end

        if options.realtime_plot && mod(iter, options.plot_interval) == 0
            interact_state = get(fig_realtime, 'UserData');
            interact_state.display_index = interact_state.display_index + 1;
            interact_state.saved_polys{interact_state.display_index} = current_poly;
            interact_state.saved_f_values(interact_state.display_index) = f_current;
            interact_state.saved_iters(interact_state.display_index) = iter;
            set(fig_realtime, 'UserData', interact_state);

            draw_current_state(fig_realtime, current_poly, f_history, iter, ...
                options.max_iter, x_min, x_max, y_min, y_max);

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
                            x_min, x_max, y_min, y_max);
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
    end

    if ~isequal(trajectory{end}, current_poly)
        trajectory{end+1} = current_poly;
    end

    if options.save_video && ~isempty(video_writer)
        close(video_writer);
        fprintf('Video saved: %s\n', options.video_filename);
    end

    if iter == options.max_iter
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

    if options.verbose
        fprintf('\n========== Gradient Descent Finished ==========\n');
        fprintf('Total iterations: %d\n', info.iterations);
        fprintf('Final objective value: f = %.6f\n', info.final_f);
        fprintf('  Distance term: d = %.6f\n', info.final_d);
        fprintf('  Energy: Phi(x) = %.6f (target Phi(p) = %.6f)\n', ...
                info.final_phi, phi_target);
    end
end

function keyPressCallback(src, event)
    state = get(src, 'UserData');
    if strcmp(event.Key, 'space')
        state.paused = ~state.paused;
    elseif strcmp(event.Key, 'leftarrow')
        state.step_back = true;
    end
    set(src, 'UserData', state);
end

function draw_current_state(fig, polygon, f_hist, current_iter, max_iter, ...
                            x_min, x_max, y_min, y_max)
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
    plot(x, y, 'k-', 'LineWidth', 2);
    plot(polygon(:, 1), polygon(:, 2), 'ko', ...
         'MarkerSize', 6, 'MarkerFaceColor', 'k');

    state = get(fig, 'UserData');
    if state.paused
        title(sprintf(['[Paused] Iteration %d/%d ', ...
                       '(Space: Resume, Left Arrow: Step Back)'], ...
                      current_iter, max_iter), ...
              'FontSize', 14, 'Color', 'r');
    else
        title(sprintf('Iteration %d/%d (Progress: %.1f%%)', ...
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
