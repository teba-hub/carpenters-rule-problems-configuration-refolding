function d = corresponding_vertex_distance(current_poly, target_poly)
    %CORRESPONDING_VERTEX_DISTANCE Sum corresponding-vertex distances.

    n = size(current_poly, 1);
    if size(target_poly, 1) ~= n
        error(['Current and target cycle linkages must have the same ', ...
               'vertex count.']);
    end

    d = 0;
    for i = 1:n
        dist = polygon_geometry('point_distance', ...
                                current_poly(i, :), target_poly(i, :));
        d = d + dist;
    end
end
