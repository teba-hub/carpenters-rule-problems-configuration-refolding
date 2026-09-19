function polygon = get_polygon(n, mode, generation_options)
    %GET_POLYGON Acquire a polygon by mouse input or random generation.
    %   The returned polygon is translated and rotated so that its first
    %   vertex is at the origin and its second lies on the positive x-axis.

    if nargin < 3
        generation_options = struct();
    end
    generation_options = apply_generation_defaults(generation_options);

    switch mode
        case 'mouse'
            polygon = get_polygon_from_mouse(n, generation_options);
        case 'random'
            polygon = generate_random_simple_polygon(n, generation_options);
        otherwise
            error('Unknown mode: %s. Use ''mouse'' or ''random''.', mode);
    end
end

function options = apply_generation_defaults(options)
    if ~isfield(options, 'mouse_x_limits')
        options.mouse_x_limits = [-200, 100];
    end
    if ~isfield(options, 'mouse_y_limits')
        options.mouse_y_limits = [-200, 100];
    end
    if ~isfield(options, 'random_max_attempts')
        options.random_max_attempts = 100;
    end
    if ~isfield(options, 'random_radius_min')
        options.random_radius_min = 0.3;
    end
    if ~isfield(options, 'random_radius_max')
        options.random_radius_max = 1.0;
    end
end

function polygon = get_polygon_from_mouse(n, options)
    figure('Name', 'Polygon Input', 'NumberTitle', 'off');
    axis equal;
    grid on;
    xlim(options.mouse_x_limits);
    ylim(options.mouse_y_limits);
    hold on;

    title(sprintf('Select %d vertices in boundary order', n), 'FontSize', 12);
    xlabel('X');
    ylabel('Y');

    polygon_raw = zeros(n, 2);
    for i = 1:n
        title(sprintf('Select vertex %d of %d', i, n), 'FontSize', 12);
        [x, y] = ginput(1);
        polygon_raw(i, :) = [x, y];

        plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
        if i > 1
            plot([polygon_raw(i-1, 1), x], [polygon_raw(i-1, 2), y], ...
                 'k-', 'LineWidth', 2);
        end
        if i == n
            plot([x, polygon_raw(1, 1)], [y, polygon_raw(1, 2)], ...
                 'k-', 'LineWidth', 2);
        end

        drawnow;
    end

    title('User-Defined Polygon', 'FontSize', 12);

    if ~polygon_utils('check_simple_polygon', polygon_raw)
        warning('The polygon self-intersects. Please enter it again.');
        close(gcf);
        polygon = get_polygon_from_mouse(n, options);
        return;
    end

    polygon = polygon_utils('transform_to_standard_form', polygon_raw);

    figure('Name', 'Standard Form', 'NumberTitle', 'off');
    subplot(1, 2, 1);
    polygon_utils('plot_polygon', polygon_raw, 'b-');
    title('Raw Input');

    subplot(1, 2, 2);
    polygon_utils('plot_polygon', polygon, 'r-');
    title('Standard Form');

    fprintf(['Polygon created: v1=(%.4f, %.4f), ' ...
             'v2=(%.4f, %.4f)\n'], ...
            polygon(1,1), polygon(1,2), polygon(2,1), polygon(2,2));
end

function polygon = generate_random_simple_polygon(n, options)
    max_attempts = options.random_max_attempts;

    for attempt = 1:max_attempts
        angles = sort(rand(n, 1) * 2 * pi);
        radius_span = options.random_radius_max - options.random_radius_min;
        radii = options.random_radius_min + radius_span * rand(n, 1);
        x = radii .* cos(angles);
        y = radii .* sin(angles);
        polygon_raw = [x, y];

        if polygon_utils('check_simple_polygon', polygon_raw)
            polygon = polygon_utils('transform_to_standard_form', polygon_raw);
            fprintf('Random polygon generated on attempt %d.\n', attempt);
            return;
        end
    end

    error('Unable to generate a simple polygon after %d attempts.', ...
          max_attempts);
end
