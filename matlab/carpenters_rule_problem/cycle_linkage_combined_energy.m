function energy = cycle_linkage_combined_energy(angles, anchor, lengths, weight)
    %CYCLE_LINKAGE_COMBINED_ENERGY Evaluate -area + weight*contact energy.

    signed_area = cycle_linkage_signed_area(angles, anchor, lengths);
    contact_energy = cycle_linkage_contact_energy(angles, anchor, lengths);
    energy = -abs(signed_area) + weight * contact_energy;
end
