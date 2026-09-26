function deform_arm_linkage(angles, anchor, lengths, initial_points, ...
                            options, plot_style)
    %DEFORM_ARM_LINKAGE Run the original arm-linkage descent iteration.

    pause_flag = false;

    fig = figure('Name', ...
                 'Carpenter''s Rule Problem - Arm Linkage Deformation', ...
                 'NumberTitle', 'off', 'Color', 'w');
    set(fig, 'KeyPressFcn', @key_press_callback);
    ax = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    grid(ax, 'on');
    box(ax, 'on');
    view_radius = max(plot_style.view_padding_factor * sum(lengths), 1);
    xlim(ax, anchor(1) + [-view_radius, view_radius]);
    ylim(ax, anchor(2) + [-view_radius, view_radius]);
    xlabel(ax, 'X');
    ylabel(ax, 'Y');

    linkage_plot = plot(ax, initial_points(:, 1), initial_points(:, 2), ...
        'ko-', 'MarkerFaceColor', 'k', ...
        'LineWidth', plot_style.line_width, ...
        'MarkerSize', plot_style.marker_size);
    title(ax, 'Initial Arm Linkage', 'FontSize', plot_style.font_size);

    learning_rate = options.learning_rate;
    tolerance = options.arm_linkage.tolerance;
    finite_difference_step = ...
        options.arm_linkage.finite_difference_step;
    max_iterations = options.max_iterations;

    for iteration = 1:max_iterations
        if pause_flag
            while pause_flag
                drawnow;
            end
        end

        [energy_value, normalized_gradient, gradient_norm] = ...
            arm_linkage_energy_gradient(angles, anchor, lengths, ...
                                        finite_difference_step);
        new_angles = angles - learning_rate * normalized_gradient;
        new_points = reconstruct_linkage_vertices( ...
            new_angles, anchor, lengths);
        endpoint_distance = distance_first_last(new_points);

        set(linkage_plot, 'XData', new_points(:, 1), ...
                          'YData', new_points(:, 2));
        title(ax, sprintf(['Iteration: %d | Energy: %.4e | ', ...
                          'Gradient norm: %.4e | Endpoint distance: %.4e'], ...
                         iteration, energy_value, gradient_norm, ...
                         endpoint_distance), ...
              'FontSize', plot_style.font_size);
        drawnow;

        if gradient_norm < tolerance
            fprintf('Arm-linkage optimization converged at iteration %d.\n', ...
                    iteration);
            break;
        end
        angles = new_angles;
    end

    if iteration == max_iterations
        fprintf('Arm-linkage optimization reached the maximum iteration count.\n');
    end

    function key_press_callback(~, event)
        if strcmpi(event.Key, 'space')
            pause_flag = ~pause_flag;
            if pause_flag
                fprintf('Deformation paused. Press Space to resume.\n');
            else
                fprintf('Deformation resumed.\n');
            end
        end
    end
end

function distance = distance_first_last(points)
    first_point = points(1, :);
    last_point = points(end, :);
    distance = norm(first_point - last_point);
end
