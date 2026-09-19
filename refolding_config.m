function config = refolding_config()
    %REFOLDING_CONFIG User-adjustable settings for the refolding demo.
    %   Edit this file to change inputs, optimization settings, or output.

    %% Polygon generation
    config.n = 12;
    config.generation.mode = 'mouse';  % 'mouse' or 'random'

    % Mouse-input coordinate range
    config.generation.mouse_x_limits = [-120, 120];
    config.generation.mouse_y_limits = [-120, 120];

    % Random-polygon generation
    config.generation.random_max_attempts = 100;
    config.generation.random_radius_min = 0.3;
    config.generation.random_radius_max = 1.0;

    %% Optimization
    config.optimization.c = 0.1;
    config.optimization.step_size = 0.1;
    config.optimization.max_iter = 40000;
    config.optimization.tolerance = 1e-2;
    config.optimization.save_interval = 1;
    config.optimization.verbose = true;

    %% Real-time visualization and recording
    config.optimization.realtime_plot = true;
    config.optimization.plot_interval = 2;
    config.optimization.save_video = false;
    config.optimization.video_filename = 'morphing.mp4';
    config.optimization.video_fps = 30;

    %% Result figures
    config.display.show_initial_comparison = true;
    config.display.show_objective_history = true;
    config.display.show_final_comparison = true;

    %% Eight-panel summary image
    config.summary.enabled = true;
    config.summary.save_image = false;
    config.summary.filename = 'polygon_morphing_summary.png';
    config.summary.coverage = 0.80;

    %% Optional trajectory replay
    config.replay.enabled = false;
    config.replay.fps = 30;
    config.replay.show_reference = true;
    config.replay.show_energy_plot = true;
    config.replay.save_video = false;
    config.replay.video_filename = 'polygon_morphing_replay.mp4';
end
