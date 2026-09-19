function results = run_refolding_demo(config)
    %RUN_REFOLDING_DEMO Run polygon input, optimization, and visualization.

    fprintf('========================================\n');
    fprintf('     Planar Polygon Refolding Demo\n');
    fprintf('========================================\n\n');

    n = config.n;
    mode = config.generation.mode;

    fprintf('[Configuration]\n');
    fprintf('Number of vertices: %d\n', n);
    fprintf('Generation mode: %s\n', mode);

    fprintf('\n[Polygon Generation]\n');
    switch mode
        case 'random'
            fprintf('Generating the initial random polygon...\n');
            initial_poly = get_polygon(n, mode, config.generation);

            fprintf('Generating the target random polygon...\n');
            target_poly = get_polygon(n, mode, config.generation);

        case 'mouse'
            fprintf('Select the initial polygon with the mouse...\n');
            initial_poly = get_polygon(n, mode, config.generation);

            fprintf('Select the target polygon with the mouse...\n');
            target_poly = get_polygon(n, mode, config.generation);

        otherwise
            error('Unknown generation mode: %s. Use ''random'' or ''mouse''.', mode);
    end

    if config.display.show_initial_comparison
        figure('Name', 'Initial State');
        subplot(1, 2, 1);
        polygon_utils('plot_polygon', initial_poly, 'b-');
        title('Initial Polygon', 'FontSize', 12);

        subplot(1, 2, 2);
        polygon_utils('plot_polygon', target_poly, 'r-');
        title('Target Polygon', 'FontSize', 12);
    end

    options = config.optimization;
    fprintf('\n[Gradient-Descent Settings]\n');
    fprintf('Energy weight c: %.2f\n', options.c);
    fprintf('Initial step size: %.4f\n', options.step_size);
    fprintf('Maximum iterations: %d\n', options.max_iter);
    fprintf('Real-time visualization: %s\n', ...
            enabled_text(options.realtime_plot));
    if options.realtime_plot
        fprintf('Plot interval: every %d iterations\n', options.plot_interval);
    end

    fprintf('\n[Optimization]\n');
    [trajectory, f_history, info] = ...
        gradient_descent(initial_poly, target_poly, options);

    fprintf('\n[Optimization Results]\n');
    fprintf('Iterations: %d\n', info.iterations);
    fprintf('Convergence status: %s\n', ...
            convergence_text(info.converged));
    fprintf('Final objective value: f = %.6f\n', info.final_f);
    fprintf('Final distance term: d = %.6f\n', info.final_d);

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
        figure('Name', 'Final Comparison');
        subplot(1, 3, 1);
        polygon_utils('plot_polygon', initial_poly, 'b-');
        title('Initial Polygon');

        subplot(1, 3, 2);
        polygon_utils('plot_polygon', trajectory{end}, 'g-');
        title('Final Polygon');

        subplot(1, 3, 3);
        polygon_utils('plot_polygon', target_poly, 'r-');
        title('Target Polygon');
    end

    if config.summary.enabled
        fprintf('\n[Summary Image]\n');
        generate_summary_image(trajectory, ...
                               config.summary.save_image, ...
                               config.summary.filename, ...
                               config.summary.coverage);
    end

    if config.replay.enabled
        fprintf('\n[Trajectory Replay]\n');
        replay_options = rmfield(config.replay, 'enabled');
        visualize_morphing(trajectory, initial_poly, target_poly, ...
                           f_history, replay_options);
    end

    results.initial_polygon = initial_poly;
    results.target_polygon = target_poly;
    results.trajectory = trajectory;
    results.objective_history = f_history;
    results.optimization_info = info;

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
