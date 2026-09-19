function varargout = polygon_utils(func_name, varargin)
    %POLYGON_UTILS Dispatch basic polygon operations used by the project.

    switch func_name
        case 'point_distance'
            varargout{1} = point_distance(varargin{:});
        case 'transform_to_standard_form'
            varargout{1} = transform_to_standard_form(varargin{:});
        case 'check_simple_polygon'
            varargout{1} = check_simple_polygon(varargin{:});
        case 'plot_polygon'
            plot_polygon(varargin{:});
        otherwise
            error('Unknown polygon utility: %s', func_name);
    end
end

function d = point_distance(p1, p2)
    d = sqrt((p1(1) - p2(1))^2 + (p1(2) - p2(2))^2);
end

function polygon_std = transform_to_standard_form(polygon)
    % Move the first vertex to the origin and rotate the second onto +X.
    v1 = polygon(1, :);
    polygon = polygon - v1;

    v2 = polygon(2, :);
    theta = atan2(v2(2), v2(1));
    R = [cos(-theta), -sin(-theta); ...
         sin(-theta),  cos(-theta)];
    polygon_std = (R * polygon')';
    polygon_std(2, 2) = 0;
end

function is_simple = check_simple_polygon(polygon)
    n = size(polygon, 1);
    is_simple = true;

    for i = 1:n
        for j = i+2:n
            if j == i+1 || (i == 1 && j == n)
                continue;
            end

            p1 = polygon(i, :);
            p2 = polygon(mod(i, n) + 1, :);
            p3 = polygon(j, :);
            p4 = polygon(mod(j, n) + 1, :);

            if segments_intersect(p1, p2, p3, p4)
                is_simple = false;
                return;
            end
        end
    end
end

function intersect = segments_intersect(p1, p2, p3, p4)
    d1 = cross_product_2d(p3 - p1, p2 - p1);
    d2 = cross_product_2d(p4 - p1, p2 - p1);
    d3 = cross_product_2d(p1 - p3, p4 - p3);
    d4 = cross_product_2d(p2 - p3, p4 - p3);

    if d1 * d2 < 0 && d3 * d4 < 0
        intersect = true;
    else
        intersect = false;
    end
end

function cp = cross_product_2d(v1, v2)
    cp = v1(1) * v2(2) - v1(2) * v2(1);
end

function plot_polygon(polygon, varargin)
    if nargin > 1
        style = varargin{1};
    else
        style = 'b-';
    end

    x = [polygon(:, 1); polygon(1, 1)];
    y = [polygon(:, 2); polygon(1, 2)];

    plot(x, y, style, 'LineWidth', 2);
    hold on;
    plot(polygon(:, 1), polygon(:, 2), 'ro', ...
         'MarkerSize', 6, 'MarkerFaceColor', 'r');
    axis equal;
    grid on;
end
