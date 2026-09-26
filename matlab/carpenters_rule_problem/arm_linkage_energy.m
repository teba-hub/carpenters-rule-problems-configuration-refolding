function energy = arm_linkage_energy(angles, anchor, lengths)
    %ARM_LINKAGE_ENERGY Evaluate the original arm-linkage energy.

    if length(angles) ~= length(lengths)
        error('The number of angles must match the number of segments.');
    end

    points = reconstruct_linkage_vertices(angles, anchor, lengths);
    n = length(lengths) + 1;
    energy = 0;

    for edge_start = 1:n-1
        edge_end = edge_start + 1;
        for vertex = 1:n
            if vertex == edge_start || vertex == edge_end
                continue;
            end

            distance_ij = norm(points(vertex, :) - ...
                               points(edge_start, :));
            distance_ik = norm(points(vertex, :) - ...
                               points(edge_end, :));
            edge_length = norm(points(edge_start, :) - ...
                               points(edge_end, :));
            denominator = distance_ij + distance_ik - edge_length;

            if denominator <= 1e-10
                energy = energy + 1e10;
            else
                energy = energy + 1 / denominator^2;
            end
        end
    end

    energy = energy - norm(points(1, :) - points(end, :));
end
