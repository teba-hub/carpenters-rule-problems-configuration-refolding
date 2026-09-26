function phi = configuration_contact_energy(polygon)
    %CONFIGURATION_CONTACT_ENERGY Evaluate the polygon contact energy.
    %   Phi(p) = sum 1/(||v_i-v_k|| + ||v_j-v_k|| - ||v_i-v_j||)^2,
    %   summed over every edge [v_i,v_j] and every nonincident vertex v_k.

    n = size(polygon, 1);
    phi = 0;

    for i = 1:n
        vi_idx = i;
        vj_idx = mod(i, n) + 1;
        vi = polygon(vi_idx, :);
        vj = polygon(vj_idx, :);
        edge_length = polygon_geometry('point_distance', vi, vj);

        for k = 1:n
            if k == vi_idx || k == vj_idx
                continue;
            end

            vk = polygon(k, :);
            dist_ik = polygon_geometry('point_distance', vi, vk);
            dist_jk = polygon_geometry('point_distance', vj, vk);
            denominator = dist_ik + dist_jk - edge_length;

            if denominator <= 1e-10
                warning(['The energy denominator is nonpositive or too ' ...
                         'small; the cycle linkage may be close to ', ...
                         'self-contact.']);
                phi = Inf;
                return;
            end

            phi = phi + 1 / (denominator^2);
        end
    end
end
