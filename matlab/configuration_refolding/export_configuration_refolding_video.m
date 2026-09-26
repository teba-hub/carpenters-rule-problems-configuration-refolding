function video_info = export_configuration_refolding_video( ...
        trajectory, target_polygon, output_file, options)
    %EXPORT_CONFIGURATION_REFOLDING_VIDEO Export a refolding animation.

    validateattributes(trajectory, {'cell'}, {'nonempty'});
    validateattributes(options.duration_seconds, {'numeric'}, ...
                       {'scalar', 'real', 'finite', 'positive'});
    validateattributes(options.fps, {'numeric'}, ...
                       {'scalar', 'real', 'finite', 'positive'});
    if ~isfield(options, 'plot_style')
        options.plot_style = struct();
    end
    options.plot_style = resolve_plot_style(options.plot_style);

    [~, ~, extension] = fileparts(output_file);
    if ~strcmpi(extension, '.mp4')
        error('The video filename must use the .mp4 extension.');
    end

    frame_count = max(2, round(options.duration_seconds * options.fps));
    frame_rate = frame_count / options.duration_seconds;
    n_states = numel(trajectory);

    reference_size = size(trajectory{1});
    if ~isequal(size(target_polygon), reference_size)
        error(['The target cycle linkage must match the trajectory ', ...
               'dimensions.']);
    end
    for state_index = 1:n_states
        if ~isequal(size(trajectory{state_index}), reference_size)
            error('All trajectory states must have the same dimensions.');
        end
    end

    cumulative_path = zeros(1, n_states);
    for state_index = 2:n_states
        displacement = trajectory{state_index} - trajectory{state_index-1};
        cumulative_path(state_index) = cumulative_path(state_index-1) + ...
                                       norm(displacement, 'fro');
    end
    sample_positions = linspace(0, cumulative_path(end), frame_count);

    all_points = [vertcat(trajectory{:}); target_polygon];
    x_center = (min(all_points(:, 1)) + max(all_points(:, 1))) / 2;
    y_center = (min(all_points(:, 2)) + max(all_points(:, 2))) / 2;
    x_span = max(all_points(:, 1)) - min(all_points(:, 1));
    y_span = max(all_points(:, 2)) - min(all_points(:, 2));
    view_span = max([x_span, y_span, 1]);
    half_width = 0.60 * view_span;

    writer = VideoWriter(output_file, 'MPEG-4');
    writer.FrameRate = frame_rate;
    open(writer);

    fig = figure('Name', 'Exporting Configuration Refolding Video', ...
                 'Color', 'w', ...
                 'Position', [50, 100, 1500, 520]);
    layout = tiledlayout(fig, 1, 3, ...
                         'TileSpacing', 'compact', ...
                         'Padding', 'compact');
    initial_ax = nexttile(layout, 1);
    current_ax = nexttile(layout, 2);
    target_ax = nexttile(layout, 3);

    initial_polygon = trajectory{1};
    plot_reference_polygon(initial_ax, initial_polygon, ...
                           [0.1, 0.35, 0.9], 'Initial Cycle Linkage', ...
                           x_center, y_center, half_width, ...
                           options.plot_style);
    plot_reference_polygon(target_ax, target_polygon, ...
                           [0.9, 0.15, 0.15], 'Target Cycle Linkage', ...
                           x_center, y_center, half_width, ...
                           options.plot_style);

    initial_x = [initial_polygon(:, 1); initial_polygon(1, 1)];
    initial_y = [initial_polygon(:, 2); initial_polygon(1, 2)];
    edge_plot = plot(current_ax, initial_x, initial_y, ...
                     'k-', 'LineWidth', options.plot_style.line_width);
    hold(current_ax, 'on');
    vertex_plot = plot(current_ax, ...
                       initial_polygon(:, 1), initial_polygon(:, 2), ...
                       'ko', ...
                       'MarkerSize', options.plot_style.marker_size, ...
                       'MarkerFaceColor', 'k');
    hold(current_ax, 'off');
    configure_axes(current_ax, x_center, y_center, half_width);
    title_handle = title(current_ax, 'Current Cycle Linkage: 0.0%');

    try
        segment_index = 1;
        for frame_index = 1:frame_count
            if frame_index == 1
                polygon = trajectory{1};
            elseif frame_index == frame_count
                polygon = trajectory{end};
            elseif cumulative_path(end) == 0 || n_states == 1
                polygon = trajectory{end};
            else
                position = sample_positions(frame_index);
                while segment_index < n_states - 1 && ...
                        cumulative_path(segment_index + 1) < position
                    segment_index = segment_index + 1;
                end

                segment_length = cumulative_path(segment_index + 1) - ...
                                 cumulative_path(segment_index);
                if segment_length > 0
                    alpha = (position - cumulative_path(segment_index)) / ...
                            segment_length;
                else
                    alpha = 0;
                end

                polygon = (1 - alpha) * trajectory{segment_index} + ...
                          alpha * trajectory{segment_index + 1};
            end

            x_closed = [polygon(:, 1); polygon(1, 1)];
            y_closed = [polygon(:, 2); polygon(1, 2)];
            set(edge_plot, 'XData', x_closed, 'YData', y_closed);
            set(vertex_plot, ...
                'XData', polygon(:, 1), ...
                'YData', polygon(:, 2));
            set(title_handle, 'String', ...
                sprintf('Current Cycle Linkage: %.1f%%', ...
                        100 * (frame_index - 1) / (frame_count - 1)));
            drawnow;

            frame_data = getframe(fig);
            frame_height = 2 * floor(size(frame_data.cdata, 1) / 2);
            frame_width = 2 * floor(size(frame_data.cdata, 2) / 2);
            frame_data.cdata = frame_data.cdata(1:frame_height, ...
                                                1:frame_width, :);
            writeVideo(writer, frame_data);
        end

        close(writer);
        close(fig);
    catch exception
        try
            close(writer);
        catch
        end
        if isgraphics(fig)
            close(fig);
        end
        rethrow(exception);
    end

    video_info.file = output_file;
    video_info.duration_seconds = options.duration_seconds;
    video_info.fps = frame_rate;
    video_info.frame_count = frame_count;

    fprintf('Video saved: %s\n', output_file);
    fprintf('Duration: %.1f seconds (%d frames at %.2f fps)\n', ...
            video_info.duration_seconds, ...
            video_info.frame_count, ...
            video_info.fps);
end

function plot_reference_polygon(ax, polygon, color, title_text, ...
                                x_center, y_center, half_width, plot_style)
    x_closed = [polygon(:, 1); polygon(1, 1)];
    y_closed = [polygon(:, 2); polygon(1, 2)];

    plot(ax, x_closed, y_closed, '-', ...
         'Color', color, 'LineWidth', plot_style.line_width);
    hold(ax, 'on');
    plot(ax, polygon(:, 1), polygon(:, 2), 'o', ...
         'Color', color, ...
         'MarkerSize', plot_style.marker_size, ...
         'MarkerFaceColor', color);
    hold(ax, 'off');

    configure_axes(ax, x_center, y_center, half_width);
    title(ax, title_text);
end

function configure_axes(ax, x_center, y_center, half_width)
    axis(ax, 'equal');
    xlim(ax, x_center + [-half_width, half_width]);
    ylim(ax, y_center + [-half_width, half_width]);
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    box(ax, 'on');
    grid(ax, 'off');
end
