function energy = cycle_linkage_energy(angles, anchor, lengths)
    %CYCLE_LINKAGE_ENERGY Evaluate the original cycle-linkage energy.

    points = reconstruct_linkage_vertices(angles, anchor, lengths);
    signed_area = cycle_linkage_signed_area(angles, anchor, lengths);
    orientation = sign(signed_area);

    n = size(points, 1);
    reflex_penalty = 0;

    for index = 1:n
        previous_index = index - 1;
        if previous_index == 0
            previous_index = n;
        end
        next_index = index + 1;
        if next_index > n
            next_index = 1;
        end

        previous_point = points(previous_index, :);
        current_point = points(index, :);
        next_point = points(next_index, :);

        previous_edge = current_point - previous_point;
        next_edge = next_point - current_point;
        cross_product = previous_edge(1) * next_edge(2) ...
                      - previous_edge(2) * next_edge(1);
        dot_product = previous_edge(1) * next_edge(1) ...
                    + previous_edge(2) * next_edge(2);
        turning_angle = atan2(cross_product, dot_product);

        oriented_angle = orientation * turning_angle;
        if oriented_angle < 0
            reflex_penalty = reflex_penalty + oriented_angle^2;
        end
    end

    contact_energy = cycle_linkage_contact_energy( ...
        angles, anchor, lengths);
    energy = -abs(signed_area) + reflex_penalty * contact_energy;
end
