function [points, lengths, angles, linkage_type] = ...
        acquire_linkage_input(input_options, plot_style)
    %ACQUIRE_LINKAGE_INPUT Acquire an arm or cycle linkage with the mouse.
    %   Press Enter for an arm linkage or Space for a cycle linkage.

    fig = figure('Name', 'Carpenter''s Rule Problem - Linkage Input', ...
                 'NumberTitle', 'off', 'Color', 'w');
    ax = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    grid(ax, 'on');
    box(ax, 'on');
    xticks(ax, input_options.tick_values);
    yticks(ax, input_options.tick_values);
    axis(ax, input_options.axis_limits);
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    title(ax, ['Click to add vertices | Enter: arm linkage | ', ...
               'Space: cycle linkage'], ...
          'FontSize', plot_style.font_size);

    points = [];
    set(fig, 'UserData', 'waiting');
    set(fig, 'WindowButtonDownFcn', @add_point);
    set(fig, 'KeyPressFcn', @check_key);

    waitfor(fig, 'UserData', 'finished');

    if isappdata(fig, 'linkage_type')
        linkage_type = getappdata(fig, 'linkage_type');
    else
        linkage_type = 1;
    end

    if size(points, 1) >= 2
        lengths = sqrt(sum(diff(points).^2, 2));
        dx = diff(points(:, 1));
        dy = diff(points(:, 2));
        angles = atan2(dy, dx);
    else
        lengths = [];
        angles = [];
    end

    function add_point(~, ~)
        current_point = get(ax, 'CurrentPoint');
        new_point = current_point(1, 1:2);
        points = [points; new_point];

        plot(ax, new_point(1), new_point(2), 'ko', ...
             'MarkerFaceColor', 'k', ...
             'MarkerSize', plot_style.marker_size);
        if size(points, 1) >= 2
            line(ax, points(end-1:end, 1), points(end-1:end, 2), ...
                 'Color', 'k', 'LineWidth', plot_style.line_width);
        end
    end

    function check_key(source, event)
        if strcmp(event.Key, 'return')
            set(source, 'UserData', 'finished');
            setappdata(source, 'linkage_type', 1);
        elseif strcmpi(event.Key, 'space')
            handle_closure(source, 0);
        end
    end

    function handle_closure(source, type_value)
        if size(points, 1) < 3
            title(ax, 'At least three vertices are required for a cycle linkage.', ...
                  'FontSize', plot_style.font_size);
        else
            first_point = points(1, :);
            last_point = points(end, :);
            line(ax, [last_point(1), first_point(1)], ...
                     [last_point(2), first_point(2)], ...
                     'Color', 'k', 'LineWidth', plot_style.line_width);
            set(source, 'UserData', 'finished');
            setappdata(source, 'linkage_type', type_value);
        end
    end
end
