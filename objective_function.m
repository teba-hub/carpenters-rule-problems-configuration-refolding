function [f_val, d_val, phi_x, energy_diff] = ...
        objective_function(current_poly, target_poly, phi_target, c)
    %OBJECTIVE_FUNCTION Evaluate f(x) = d(x) + c[Phi(p) - Phi(x)]^2.

    d_val = compute_distance_d(current_poly, target_poly);
    phi_x = compute_energy_phi(current_poly);

    if isinf(phi_x)
        f_val = Inf;
        energy_diff = Inf;
        return;
    end

    energy_diff = phi_target - phi_x;
    f_val = d_val + c * (energy_diff^2);
end
