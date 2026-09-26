function results = execute_configuration_refolding(config)
    %EXECUTE_CONFIGURATION_REFOLDING Run the complete refolding workflow.

    fprintf('========================================\n');
    fprintf('          Planar Configuration Refolding\n');
    fprintf('========================================\n\n');

    n = config.n;
    mode = config.generation.mode;

    fprintf('[Configuration]\n');
    fprintf('Number of vertices: %d\n', n);
    fprintf('Generation mode: %s\n', mode);

    fprintf('\n[Cycle Linkage Generation]\n');
    switch mode
        case 'random'
            fprintf('Generating the initial random cycle linkage...\n');
            initial_poly = acquire_cycle_linkage( ...
                n, mode, config.generation, config.style);

            fprintf('Generating the target random cycle linkage...\n');
            target_poly = acquire_cycle_linkage( ...
                n, mode, config.generation, config.style);

        case 'mouse'
            fprintf('Select the initial cycle linkage with the mouse...\n');
            initial_poly = acquire_cycle_linkage( ...
                n, mode, config.generation, config.style);

            fprintf('Select the target cycle linkage with the mouse...\n');
            target_poly = acquire_cycle_linkage( ...
                n, mode, config.generation, config.style);

        otherwise
            error('Unknown generation mode: %s. Use ''random'' or ''mouse''.', mode);
    end

    if config.display.show_initial_comparison
        figure('Name', 'Initial Cycle Linkages');
        subplot(1, 2, 1);
        polygon_geometry('plot_polygon', initial_poly, 'b-', config.style);
        title('Initial Cycle Linkage', 'FontSize', 12);

        subplot(1, 2, 2);
        polygon_geometry('plot_polygon', target_poly, 'r-', config.style);
        title('Target Cycle Linkage', 'FontSize', 12);
    end

    options = config.optimization;
    options.plot_style = config.style;
    fprintf('\n[Gradient-Descent Settings]\n');
    fprintf('Energy weight c: %.2f\n', options.c);
    if options.dynamic_c.enabled
        fprintf(['Dynamic c: enabled (trigger below %.0f%% initial ', ...
                 'distance, step <= %.1e for %d iterations)\n'], ...
                100 * options.dynamic_c.trigger_distance_ratio, ...
                options.dynamic_c.trigger_step_size, ...
                options.dynamic_c.trigger_iterations);
        fprintf('Dynamic c minimum: %.4g\n', ...
                options.dynamic_c.minimum_c);
    else
        fprintf('Dynamic c: disabled\n');
    end
    fprintf('Initial step size: %.4f\n', options.step_size);
    fprintf('Line search: up to %d backtracks, minimum step %.1e\n', ...
            options.line_search.max_backtracks, ...
            options.line_search.minimum_step_size);
    fprintf('Maximum iterations: %d\n', options.max_iter);
    fprintf('Gradient tolerance: %.2e\n', options.tolerance);
    fprintf('Stagnation window: %d iterations\n', ...
            options.stagnation_iterations);
    fprintf('Real-time visualization: %s\n', ...
            enabled_text(options.realtime_plot));
    if options.realtime_plot
        fprintf('Plot interval: every %d iterations\n', options.plot_interval);
        fprintf('Manual stop: press Esc to stop optimization normally\n');
    end
    fprintf('Video export: %s\n', enabled_text(config.video.enabled));

    fprintf('\n[Optimization]\n');
    [trajectory, f_history, info] = ...
        optimize_configuration_refolding(initial_poly, target_poly, options);

    fprintf('\n[Optimization Results]\n');
    fprintf('Iterations: %d\n', info.iterations);
    fprintf('Convergence status: %s\n', ...
            convergence_text(info.converged));
    fprintf('Termination reason: %s\n', info.termination_reason);
    fprintf('Final objective value: f = %.6f\n', info.final_f);
    fprintf('Final distance term: d = %.6f\n', info.final_d);
    fprintf('Final energy weight: c = %.6g (%d updates)\n', ...
            info.final_c, info.c_switches);
    fprintf('Backtracking reductions: %d; failed searches: %d\n', ...
            info.total_backtracks, info.failed_line_searches);

    if config.display.show_objective_history
        figure('Name', 'Optimization History');
        subplot(2, 1, 1);
        plot(f_history, 'b-', 'LineWidth', 2);
        xlabel('Iteration');
        ylabel('Objective value f(x)');
        title('Objective History');
        grid on;

        subplot(2, 1, 2);
        semilogy(f_history, 'r-', 'LineWidth', 2);
        xlabel('Iteration');
        ylabel('Objective value f(x), logarithmic scale');
        title('Objective History (Log Scale)');
        grid on;
    end

    if config.display.show_final_comparison
        figure('Name', 'Final Cycle Linkage Comparison');
        subplot(1, 3, 1);
        polygon_geometry('plot_polygon', initial_poly, 'b-', config.style);
        title('Initial Cycle Linkage');

        subplot(1, 3, 2);
        polygon_geometry('plot_polygon', trajectory{end}, 'g-', config.style);
        title('Final Cycle Linkage');

        subplot(1, 3, 3);
        polygon_geometry('plot_polygon', target_poly, 'r-', config.style);
        title('Target Cycle Linkage');
    end

    video_file = '';
    video_info = struct();
    if config.video.enabled
        fprintf('\n[Video Export]\n');
        if ~info.converged
            fprintf(['Optimization ended without convergence. Exporting ', ...
                     'the available trajectory anyway.\n']);
        end

        project_dir = fileparts(mfilename('fullpath'));
        video_file = fullfile(project_dir, config.video.filename);
        video_options = config.video;
        video_options.plot_style = config.style;
        video_info = export_configuration_refolding_video(trajectory, ...
                                             target_poly, ...
                                             video_file, ...
                                             video_options);
    end

    if config.summary.enabled
        fprintf('\n[Summary Image]\n');
        create_trajectory_summary(trajectory, ...
                                  config.summary.save_image, ...
                                  config.summary.filename, ...
                                  config.summary.coverage, ...
                                  config.style);
    end

    if config.replay.enabled
        fprintf('\n[Trajectory Replay]\n');
        replay_options = rmfield(config.replay, 'enabled');
        replay_options.plot_style = config.style;
        replay_configuration_trajectory(trajectory, initial_poly, ...
                                        target_poly, f_history, ...
                                        replay_options);
    end

    results.initial_polygon = initial_poly;
    results.target_polygon = target_poly;
    results.trajectory = trajectory;
    results.objective_history = f_history;
    results.optimization_info = info;
    results.video_file = video_file;
    results.video_info = video_info;

    fprintf('\n========================================\n');
    fprintf('              Run complete\n');
    fprintf('========================================\n');
end

function text = enabled_text(value)
    if value
        text = 'enabled';
    else
        text = 'disabled';
    end
end

function text = convergence_text(value)
    if value
        text = 'converged';
    else
        text = 'not converged';
    end
end
