function config = configuration_refolding_config()
    %CONFIGURATION_REFOLDING_CONFIG Settings for configuration refolding.
    %   Edit this file to change input, optimization, display, or output.

    %% Polygon generation
    config.n = 7;
    config.generation.mode = 'mouse';  % 'mouse' or 'random'

    % Mouse-input coordinate range
    config.generation.mouse_x_limits = [-120, 120];
    config.generation.mouse_y_limits = [-120, 120];

    % Random-polygon generation
    config.generation.random_max_attempts = 100;
    config.generation.random_radius_min = 0.3;
    config.generation.random_radius_max = 1.0;

    %% Polygon appearance
    config.style.line_width = 1.2;
    config.style.marker_size = 4;

    %% Optimization
    config.optimization.c = 0.03;
    config.optimization.step_size = 0.03;
    config.optimization.max_iter = 40000;

    % Monotone backtracking line search
    config.optimization.line_search.reduction_factor = 0.5;
    config.optimization.line_search.growth_factor = 1.05;
    config.optimization.line_search.max_backtracks = 30;
    config.optimization.line_search.minimum_step_size = 1e-8;

    % Dynamic energy-weight continuation near a stalled endpoint
    config.optimization.dynamic_c.enabled = true;
    config.optimization.dynamic_c.trigger_distance_ratio = 0.20;
    config.optimization.dynamic_c.trigger_step_size = 1e-3;
    config.optimization.dynamic_c.trigger_iterations = 30;
    config.optimization.dynamic_c.reduction_factor = 0.30;
    config.optimization.dynamic_c.minimum_c = 0.0001;
    config.optimization.dynamic_c.reset_step_size = 0.01;

    % Automatic termination at a stationary point or a sustained plateau
    config.optimization.tolerance = 5e-2;
    config.optimization.stagnation_tolerance = 1e-8;
    config.optimization.stagnation_iterations = 100;
    config.optimization.save_interval = 1;
    config.optimization.verbose = true;

    %% Real-time visualization
    config.optimization.realtime_plot = true;
    config.optimization.plot_interval = 2;
    % Press Esc in the real-time window to stop and continue to selected outputs.

    %% Optional video export after optimization
    % Set to true to generate an MP4, or false to skip video generation.
    config.video.enabled = false;
    config.video.duration_seconds = 15;
    config.video.fps = 30;
    config.video.filename = 'configuration_refolding.mp4';

    %% Result figures
    config.display.show_initial_comparison = true;
    config.display.show_objective_history = true;
    config.display.show_final_comparison = true;

    %% Eight-panel summary image
    config.summary.enabled = true;
    config.summary.save_image = false;
    config.summary.filename = 'configuration_refolding_summary.png';
    config.summary.coverage = 0.80;

    %% Optional trajectory replay
    config.replay.enabled = false;
    config.replay.fps = 30;
    config.replay.show_reference = true;
    config.replay.show_energy_plot = true;
end
