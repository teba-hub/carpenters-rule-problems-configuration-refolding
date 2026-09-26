function run_carpenters_rule_problem()
    %RUN_CARPENTERS_RULE_PROBLEM Run the fixed-length linkage computation.

    config = carpenters_rule_config();
    [points, lengths, angles, linkage_type] = ...
        acquire_linkage_input(config.input, config.style);

    if isempty(lengths)
        error('At least two points are required.');
    end

    anchor = points(1, :);
    options = config.optimization;

    switch linkage_type
        case 1
            deform_arm_linkage(angles, anchor, lengths, points, ...
                               options, config.style);

        case 0
            deform_cycle_linkage(angles, anchor, lengths, options, ...
                                 config.style, @cycle_linkage_energy);

        case 2
            weight = options.cycle_linkage.combined_energy_weight;
            energy_function = @(theta, p1, d) ...
                cycle_linkage_combined_energy(theta, p1, d, weight);
            deform_cycle_linkage(angles, anchor, lengths, options, ...
                                 config.style, energy_function);

        otherwise
            error('Unknown linkage type: %d.', linkage_type);
    end
end
