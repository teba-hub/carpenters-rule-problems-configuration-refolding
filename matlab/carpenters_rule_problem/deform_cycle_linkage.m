function deform_cycle_linkage(angles, anchor, lengths, options, ...
                              plot_style, energy_function)
    %DEFORM_CYCLE_LINKAGE Run the original constrained descent iteration.

    pause_flag = false;

    fig = figure('Name', ...
                 'Carpenter''s Rule Problem - Cycle Linkage Deformation', ...
                 'NumberTitle', 'off', 'Color', 'w');
    set(fig, 'KeyPressFcn', @key_press_callback);
    ax = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    grid(ax, 'on');
    box(ax, 'on');

    initial_points = reconstruct_linkage_vertices(angles, anchor, lengths);
    closing_edge_length = norm(initial_points(end, :) - anchor);
    cycle_perimeter = sum(lengths) + closing_edge_length;
    view_radius = max(0.5 * plot_style.cycle_view_scale * ...
                      cycle_perimeter, 1);
    xlim(ax, anchor(1) + [-view_radius, view_radius]);
    ylim(ax, anchor(2) + [-view_radius, view_radius]);
    xlabel(ax, 'X');
    ylabel(ax, 'Y');

    linkage_plot = plot(ax, initial_points(:, 1), initial_points(:, 2), ...
        'ko-', 'MarkerFaceColor', 'k', ...
        'LineWidth', plot_style.line_width, ...
        'MarkerSize', plot_style.marker_size);

    last_point = initial_points(end, :);
    closing_edge = line(ax, [last_point(1), anchor(1)], ...
                            [last_point(2), anchor(2)], ...
        'Color', 'k', 'LineWidth', plot_style.line_width);

    title(ax, 'Cycle Linkage Deformation', ...
          'FontSize', plot_style.font_size);
    drawnow;

    learning_rate = options.learning_rate;
    tolerance = options.cycle_linkage.tolerance;
    finite_difference_step = ...
        options.cycle_linkage.finite_difference_step;
    max_iterations = options.max_iterations;

    for iteration = 1:max_iterations
        if pause_flag
            while pause_flag
                drawnow;
            end
        end

        [normalized_direction, ~, direction] = ...
            projected_cycle_linkage_gradient( ...
                energy_function, angles, anchor, lengths, ...
                finite_difference_step);

        if norm(direction) < tolerance
            fprintf(['Projected direction norm is below the tolerance; ', ...
                     'stopping.\n']);
            break;
        end

        angles = angles - learning_rate * normalized_direction;

        new_points = reconstruct_linkage_vertices(angles, anchor, lengths);
        set(linkage_plot, 'XData', new_points(:, 1), ...
                          'YData', new_points(:, 2));

        last_point = new_points(end, :);
        set(closing_edge, 'XData', [last_point(1), anchor(1)], ...
                          'YData', [last_point(2), anchor(2)]);

        current_area = abs(cycle_linkage_signed_area( ...
            angles, anchor, lengths));
        title(ax, sprintf('Iteration: %d | Current area: %.2f', ...
                          iteration, current_area), ...
              'FontSize', plot_style.font_size);
        drawnow;
    end

    final_area = abs(cycle_linkage_signed_area(angles, anchor, lengths));
    title(ax, sprintf(['Optimization complete | Iterations: %d | ', ...
                       'Final area: %.2f'], iteration, final_area), ...
          'FontSize', plot_style.font_size);
    final_energy = energy_function(angles, anchor, lengths);
    fprintf(['Cycle-linkage optimization complete: %d iterations, ', ...
             'final energy %.6f, final area %.6f.\n'], ...
            iteration, final_energy, final_area);

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
