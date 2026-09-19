function grad = compute_gradient(current_poly, target_poly, phi_target, c)
    %COMPUTE_GRADIENT Approximate the objective gradient by forward differences.

    n = size(current_poly, 1);
    grad = zeros(n, 2);
    epsilon = 1e-6;
    f_current = objective_function(current_poly, target_poly, phi_target, c);

    for i = 1:n
        for j = 1:2
            poly_plus = current_poly;
            poly_plus(i, j) = poly_plus(i, j) + epsilon;
            f_plus = objective_function(poly_plus, target_poly, phi_target, c);
            grad(i, j) = (f_plus - f_current) / epsilon;
        end
    end
end
