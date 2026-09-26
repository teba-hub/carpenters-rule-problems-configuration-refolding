function run_smoke_tests()
    %RUN_SMOKE_TESTS Check core numerical functions without opening figures.

    test_directory = fileparts(mfilename('fullpath'));
    project_directory = fileparts(test_directory);
    carpenters_rule_directory = fullfile(project_directory, 'matlab', ...
                                         'carpenters_rule_problem');
    configuration_directory = fullfile(project_directory, 'matlab', ...
                                       'configuration_refolding');
    addpath(carpenters_rule_directory, configuration_directory);
    cleanup = onCleanup(@() rmpath(carpenters_rule_directory, ...
                                    configuration_directory));

    angles = [0.2; 1.0; 2.1; -1.2];
    anchor = [0.3, -0.4];
    lengths = [1.1; 0.9; 1.3; 0.7];
    points = reconstruct_linkage_vertices(angles, anchor, lengths);
    reconstructed_lengths = sqrt(sum(diff(points).^2, 2));
    assert(max(abs(reconstructed_lengths - lengths)) < 1e-12);
    linkage_config = carpenters_rule_config();
    view_radius = max(linkage_config.style.view_padding_factor * ...
                      sum(lengths), 1);
    assert(all(abs(points(:, 1) - anchor(1)) <= view_radius));
    assert(all(abs(points(:, 2) - anchor(2)) <= view_radius));
    assert(isfinite(arm_linkage_energy(angles, anchor, lengths)));
    assert(isfinite(cycle_linkage_energy(angles, anchor, lengths)));

    closed_angles = [0; 2*pi/3];
    closed_lengths = [1; 1];
    closed_points = reconstruct_linkage_vertices( ...
        closed_angles, anchor, closed_lengths);
    closing_length = norm(closed_points(end, :) - anchor);
    closed_perimeter = sum(closed_lengths) + closing_length;
    closed_view_radius = max(0.5 * ...
        linkage_config.style.cycle_view_scale * closed_perimeter, 1);
    assert(all(abs(closed_points(:, 1) - anchor(1)) ...
               <= closed_view_radius));
    assert(all(abs(closed_points(:, 2) - anchor(2)) ...
               <= closed_view_radius));

    config = configuration_refolding_config();
    assert(isequal(config.generation.mouse_x_limits, [-120, 120]));
    assert(isequal(config.generation.mouse_y_limits, [-120, 120]));
    assert(~config.video.enabled);

    initial_polygon = [0, 0; 1, 0; 1, 1; 0, 1];
    target_polygon = [0, 0; 1.1, 0; 0.9, 1.1; -0.1, 0.9];
    target_energy = configuration_contact_energy(target_polygon);
    objective = configuration_refolding_objective( ...
        initial_polygon, target_polygon, target_energy, ...
        config.optimization.c);
    assert(isfinite(objective));

    fprintf('All smoke tests passed.\n');
end
