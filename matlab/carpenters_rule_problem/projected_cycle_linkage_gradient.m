function [normalized_direction, energy_gradient, direction] = ...
        projected_cycle_linkage_gradient(energy_function, angles, anchor, ...
                                         lengths, step)
    %PROJECTED_CYCLE_LINKAGE_GRADIENT Project onto closure constraints.

    energy_gradient = numerical_gradient(energy_function, angles, step, ...
                                         anchor, lengths);
    cosine_gradient = numerical_gradient(@sum_cosine_constraint, ...
                                         angles, step, lengths);
    sine_gradient = numerical_gradient(@sum_sine_constraint, ...
                                       angles, step, lengths);

    matrix_a = [cosine_gradient' * cosine_gradient, ...
                cosine_gradient' * sine_gradient; ...
                cosine_gradient' * sine_gradient, ...
                sine_gradient' * sine_gradient];
    vector_b = [energy_gradient' * cosine_gradient; ...
                energy_gradient' * sine_gradient];
    coefficients = matrix_a \ vector_b;
    coefficient_a = coefficients(1);
    coefficient_b = coefficients(2);

    direction = energy_gradient ...
        - coefficient_a * cosine_gradient ...
        - coefficient_b * sine_gradient;
    normalized_direction = direction / (norm(direction) + 1e-10);
end

function gradient = numerical_gradient(function_handle, angles, step, varargin)
    n = length(angles);
    gradient = zeros(n, 1);
    for index = 1:n
        angles_plus = angles;
        angles_plus(index) = angles_plus(index) + step;
        angles_minus = angles;
        angles_minus(index) = angles_minus(index) - step;
        value_plus = function_handle(angles_plus, varargin{:});
        value_minus = function_handle(angles_minus, varargin{:});
        gradient(index) = (value_plus - value_minus) / (2 * step);
    end
end

function value = sum_cosine_constraint(angles, lengths)
    value = sum(lengths .* cos(angles));
end

function value = sum_sine_constraint(angles, lengths)
    value = sum(lengths .* sin(angles));
end
