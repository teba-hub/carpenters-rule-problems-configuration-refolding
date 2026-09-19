function generate_summary_image(trajectory, save_image, filename, coverage)
    %GENERATE_SUMMARY_IMAGE Display eight states from a refolding trajectory.
    %
    % Frames 2--7 are sampled uniformly by cumulative path length over the
    % first 80 percent of the trajectory. The first and last frames are
    % always included.

    if nargin < 2, save_image = false; end
    if nargin < 3, filename = 'polygon_morphing_summary.png'; end
    if nargin < 4, coverage = 0.80; end

    n_traj = length(trajectory);

    cumDist = zeros(1, n_traj);
    for k = 2:n_traj
        delta = trajectory{k} - trajectory{k-1};
        cumDist(k) = cumDist(k-1) + norm(delta, 'fro');
    end

    total_change = cumDist(end);

    sample_end = total_change * coverage;
    target_vals = linspace(0, sample_end, 8);
    target_vals = target_vals(2:7);

    mid_idx = zeros(1, 6);
    for k = 1:6
        [~, closest] = min(abs(cumDist - target_vals(k)));
        mid_idx(k) = max(2, min(closest, n_traj - 1));
    end

    mid_idx = unique(mid_idx);
    if length(mid_idx) < 6
        fallback = round(linspace(2, n_traj - 1, 6));
        mid_idx = unique([mid_idx, fallback]);
    end
    mid_idx = mid_idx(1:6);

    polys = cell(1, 8);
    polys{1} = trajectory{1};
    polys{8} = trajectory{end};
    for k = 1:6
        polys{k+1} = trajectory{mid_idx(k)};
    end

    fprintf(['Summary sampling: %d trajectory frames, total path ', ...
             'length %.4f, coverage %.0f%%\n'], ...
            n_traj, total_change, coverage * 100);
    fprintf('  Panel 1: frame %4d, path progress   0.0%%\n', 1);
    for k = 1:6
        prog = cumDist(mid_idx(k)) / total_change * 100;
        fprintf('  Panel %d: frame %4d, path progress %4.1f%%\n', ...
                k+1, mid_idx(k), prog);
    end
    fprintf('  Panel 8: frame %4d, path progress 100.0%%\n', n_traj);

    fig = figure('Name', 'Refolding Trajectory Summary', ...
                 'Color', 'w', ...
                 'Position', [80, 80, 1400, 680]);

    gap_h = 0.04;
    gap_v = 0.06;
    margin_l = 0.03;
    margin_r = 0.03;
    margin_b = 0.04;
    margin_t = 0.04;

    n_cols = 4;
    n_rows = 2;
    w = (1 - margin_l - margin_r - (n_cols - 1) * gap_h) / n_cols;
    h = (1 - margin_b - margin_t - (n_rows - 1) * gap_v) / n_rows;

    for idx = 1:8
        col = mod(idx - 1, n_cols);
        row = n_rows - 1 - floor((idx - 1) / n_cols);

        left = margin_l + col * (w + gap_h);
        bottom = margin_b + row * (h + gap_v);

        ax = axes('Position', [left, bottom, w, h]);

        poly = polys{idx};
        x_closed = [poly(:, 1); poly(1, 1)];
        y_closed = [poly(:, 2); poly(1, 2)];

        plot(ax, x_closed, y_closed, 'k-', 'LineWidth', 1.8);
        hold(ax, 'on');
        plot(ax, poly(:, 1), poly(:, 2), 'ko', ...
             'MarkerSize', 5, 'MarkerFaceColor', 'k');

        x_span = max(x_closed) - min(x_closed);
        y_span = max(y_closed) - min(y_closed);
        pad = max(x_span, y_span) * 0.18 + 0.05;

        xlim(ax, [min(x_closed) - pad, max(x_closed) + pad]);
        ylim(ax, [min(y_closed) - pad, max(y_closed) + pad]);

        axis(ax, 'equal', 'off');
    end

    if save_image
        try
            exportgraphics(fig, filename, 'Resolution', 150);
        catch
            saveas(fig, filename);
        end
        fprintf('Summary image saved to: %s\n', filename);
    else
        fprintf(['Summary image created but not saved. Set the corresponding ', ...
                 'option in main.m to true to save it.\n']);
    end
end
