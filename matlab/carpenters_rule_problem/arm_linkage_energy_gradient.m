function [energy, normalized_gradient, gradient_norm] = ...
        arm_linkage_energy_gradient(angles, anchor, lengths, epsilon)
    %ARM_LINKAGE_ENERGY_GRADIENT Evaluate the centered energy gradient.

    if nargin < 4
        epsilon = 1e-11;
    end
    if length(angles) ~= length(lengths)
        error('The number of angles must match the number of segments.');
    end

    gradient = zeros(size(angles));

    for index = 1:length(angles)
        angles_plus = angles;
        angles_plus(index) = angles_plus(index) + epsilon;
        energy_plus = arm_linkage_energy(angles_plus, anchor, lengths);

        angles_minus = angles;
        angles_minus(index) = angles_minus(index) - epsilon;
        energy_minus = arm_linkage_energy(angles_minus, anchor, lengths);

        gradient(index) = (energy_plus - energy_minus) / (2 * epsilon);
    end

    gradient_norm = norm(gradient);
    normalized_gradient = gradient / gradient_norm;
    energy = arm_linkage_energy(angles, anchor, lengths);
end
