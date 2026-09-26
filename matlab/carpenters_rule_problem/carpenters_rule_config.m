function config = carpenters_rule_config()
    %CARPENTERS_RULE_CONFIG User-adjustable settings for the linkage demo.
    %   Edit this file to change numerical or display parameters. The
    %   defaults reproduce the values used by the original implementation.

    %% Interactive input and axes
    config.input.axis_limits = [-5, 5, -5, 5];
    config.input.tick_values = -5:1:5;

    %% Shared appearance
    config.style.line_width = 1.2;
    config.style.marker_size = 4;
    config.style.font_size = 12;
    config.style.view_padding_factor = 1.10;
    config.style.cycle_view_scale = 0.80;

    %% Shared optimization setting
    config.optimization.learning_rate = 0.01;
    config.optimization.max_iterations = 50000;

    %% Arm-linkage settings
    config.optimization.arm_linkage.tolerance = 0.05;
    config.optimization.arm_linkage.finite_difference_step = 1e-11;

    %% Cycle-linkage settings
    config.optimization.cycle_linkage.tolerance = 0.1;
    config.optimization.cycle_linkage.finite_difference_step = 1e-10;
    config.optimization.cycle_linkage.combined_energy_weight = 0.01;
end
