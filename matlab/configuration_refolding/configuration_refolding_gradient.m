function grad = configuration_refolding_gradient( ...
        current_poly, target_poly, phi_target, c)
    %CONFIGURATION_REFOLDING_GRADIENT Use forward finite differences.

    n = size(current_poly, 1);
    grad = zeros(n, 2);
    epsilon = 1e-6;
    f_current = configuration_refolding_objective( ...
        current_poly, target_poly, phi_target, c);

    for i = 1:n
        for j = 1:2
            poly_plus = current_poly;
            poly_plus(i, j) = poly_plus(i, j) + epsilon;
            f_plus = configuration_refolding_objective( ...
                poly_plus, target_poly, phi_target, c);
            grad(i, j) = (f_plus - f_current) / epsilon;
        end
    end
end
