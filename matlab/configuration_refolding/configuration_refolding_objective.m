function [f_val, d_val, phi_x, energy_diff] = ...
        configuration_refolding_objective( ...
            current_poly, target_poly, phi_target, c)
    %CONFIGURATION_REFOLDING_OBJECTIVE Evaluate the refolding objective.

    d_val = corresponding_vertex_distance(current_poly, target_poly);
    phi_x = configuration_contact_energy(current_poly);

    if isinf(phi_x)
        f_val = Inf;
        energy_diff = Inf;
        return;
    end

    energy_diff = phi_target - phi_x;
    f_val = d_val + c * (energy_diff^2);
end
