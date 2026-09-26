function replay_configuration_trajectory( ...
        trajectory, initial_poly, target_poly, f_history, options)
    %REPLAY_CONFIGURATION_TRAJECTORY Replay a saved trajectory.
    %
    % The optional fields are fps, show_reference, save_video,
    % video_filename, and show_energy_plot.

    if nargin < 5
        options = struct();
    end
    if ~isfield(options, 'fps'), options.fps = 10; end
    if ~isfield(options, 'show_reference'), options.show_reference = true; end
    if ~isfield(options, 'save_video'), options.save_video = false; end
    if ~isfield(options, 'video_filename')
        options.video_filename = 'configuration_refolding_replay.mp4';
    end
    if ~isfield(options, 'show_energy_plot'), options.show_energy_plot = true; end
    if ~isfield(options, 'plot_style'), options.plot_style = struct(); end
    options.plot_style = resolve_plot_style(options.plot_style);

    n_frames = length(trajectory);

    fprintf('========== Configuration Refolding Replay ==========\n');
    fprintf('Total frames: %d\n', n_frames);
    fprintf('Frame rate: %d fps\n', options.fps);

    if options.show_energy_plot
        fig = figure('Name', 'Configuration Refolding', ...
                     'Position', [100, 100, 1200, 500]);
    else
        fig = figure('Name', 'Configuration Refolding', ...
                     'Position', [100, 100, 800, 600]);
    end

    if options.save_video
        v = VideoWriter(options.video_filename, 'MPEG-4');
        v.FrameRate = options.fps;
        open(v);
        fprintf('Saving video to: %s\n', options.video_filename);
    end

    all_polys = [initial_poly; target_poly];
    for i = 1:length(trajectory)
        all_polys = [all_polys; trajectory{i}]; %#ok<AGROW>
    end
    x_min = min(all_polys(:, 1)) - 0.5;
    x_max = max(all_polys(:, 1)) + 0.5;
    y_min = min(all_polys(:, 2)) - 0.5;
    y_max = max(all_polys(:, 2)) + 0.5;

    for frame = 1:n_frames
        clf(fig);

        if options.show_energy_plot
            subplot(1, 2, 1);
        end

        hold on;
        axis equal;
        grid on;
        xlim([x_min, x_max]);
        ylim([y_min, y_max]);

        if options.show_reference
            plot_polygon_filled(initial_poly, [0.7, 0.7, 1.0], 0.3, ...
                                options.plot_style);
            plot_polygon_filled(target_poly, [1.0, 0.7, 0.7], 0.3, ...
                                options.plot_style);
        end

        current_poly = trajectory{frame};
        polygon_geometry('plot_polygon', current_poly, 'g-', ...
                         options.plot_style);

        progress = (frame - 1) / (n_frames - 1) * 100;
        title(sprintf('Configuration Refolding: %.1f%% (Frame %d/%d)', ...
                      progress, frame, n_frames), ...
              'FontSize', 14, 'FontWeight', 'bold');

        if options.show_reference
            legend('Initial Cycle Linkage', 'Target Cycle Linkage', ...
                   'Current Cycle Linkage', ...
                   'Location', 'best', 'FontSize', 10);
        end

        xlabel('X');
        ylabel('Y');

        if options.show_energy_plot && nargin >= 4
            subplot(1, 2, 2);

            if frame <= length(f_history)
                current_iter = frame;
            else
                current_iter = length(f_history);
            end

            plot(1:length(f_history), f_history, 'b-', 'LineWidth', 1.5);
            hold on;
            plot(current_iter, f_history(current_iter), 'ro', ...
                 'MarkerSize', 10, 'MarkerFaceColor', 'r');

            xlabel('Iteration', 'FontSize', 12);
            ylabel('Objective value f(x)', 'FontSize', 12);
            title('Optimization Progress', ...
                  'FontSize', 14, 'FontWeight', 'bold');
            grid on;

            text(current_iter, f_history(current_iter), ...
                 sprintf('  f = %.4f', f_history(current_iter)), ...
                 'FontSize', 10, 'Color', 'r');
        end

        drawnow;

        if options.save_video
            frame_data = getframe(fig);
            writeVideo(v, frame_data);
        end

        pause(1 / options.fps);
    end

    if options.save_video
        close(v);
        fprintf('Video saved.\n');
    end

    fprintf('Replay complete.\n');
end

function plot_polygon_filled(polygon, color, alpha, plot_style)
    x = [polygon(:, 1); polygon(1, 1)];
    y = [polygon(:, 2); polygon(1, 2)];

    fill(x, y, color, 'FaceAlpha', alpha, 'EdgeColor', 'none');
    plot(x, y, 'Color', color * 0.6, ...
         'LineWidth', plot_style.line_width, 'LineStyle', '--');
    plot(polygon(:, 1), polygon(:, 2), 'o', ...
         'Color', color * 0.5, 'MarkerSize', plot_style.marker_size, ...
         'MarkerFaceColor', color);
end
