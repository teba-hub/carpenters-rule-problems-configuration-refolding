function area = cycle_linkage_signed_area(angles, anchor, lengths)
    %CYCLE_LINKAGE_SIGNED_AREA Compute signed area with the shoelace formula.

    points = reconstruct_linkage_vertices(angles, anchor, lengths);
    x = points(:, 1);
    y = points(:, 2);
    next_y = [y(2:end); y(1)];
    next_x = [x(2:end); x(1)];
    area = 0.5 * sum(x .* next_y - next_x .* y);
end
