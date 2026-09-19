function d = compute_distance_d(current_poly, target_poly)
    %COMPUTE_DISTANCE_D Sum distances between corresponding vertices.

    n = size(current_poly, 1);
    if size(target_poly, 1) ~= n
        error('Current and target polygons must have the same vertex count.');
    end

    d = 0;
    for i = 1:n
        dist = polygon_utils('point_distance', ...
                            current_poly(i, :), target_poly(i, :));
        d = d + dist;
    end
end
