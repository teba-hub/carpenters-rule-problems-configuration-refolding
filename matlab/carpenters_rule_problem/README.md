# Carpenter's Rule Problem Module

This module implements the carpenter's rule problem for fixed-length planar
linkages. The visualization consistently calls the open case an **arm
linkage** and the closed case a **cycle linkage**. A linkage is represented by
a fixed anchor, segment lengths, and segment direction angles. Coordinates are
reconstructed from those variables, so the segment lengths remain fixed
during the iteration.

## Run

Open this directory in MATLAB and run:

```matlab
run_carpenters_rule_problem
```

In the input window, click vertices in order and finish with:

- **Enter** for an arm linkage;
- **Space** for a cycle linkage using `cycle_linkage_energy`.

The combined-energy cycle-linkage implementation remains available in
`cycle_linkage_combined_energy.m` and in the reserved `case 2` branch of
`run_carpenters_rule_problem.m`, but it is intentionally not assigned to an
interactive key.

Press **Space** in the deformation window to pause or resume.

## Configuration

Edit `carpenters_rule_config.m` to change:

- input axes and ticks;
- line width, marker size, title font size, and view padding;
- learning rate and maximum iteration count;
- arm-linkage gradient step and tolerance;
- cycle-linkage gradient step, tolerance, and combined-energy weight.

The defaults reproduce the numerical parameter values in the source version.
The arm-linkage view is fixed from the total linkage length. The cycle-linkage
view is fixed from half of the complete perimeter, including the closing edge.
Its separate `cycle_view_scale` setting defaults to `0.80`, giving a tighter
frame than the conservative half-perimeter view without changing during the
deformation.

## Main files

| File | Purpose |
| --- | --- |
| `run_carpenters_rule_problem.m` | Public interactive entry point |
| `carpenters_rule_config.m` | User-adjustable settings |
| `acquire_linkage_input.m` | Mouse input and linkage-case selection |
| `deform_arm_linkage.m` | Arm-linkage iteration and display |
| `deform_cycle_linkage.m` | Projected cycle-linkage iteration and display |
| `reconstruct_linkage_vertices.m` | Recover coordinates from angles and lengths |
| `arm_linkage_energy.m` | Arm-linkage energy |
| `arm_linkage_energy_gradient.m` | Centered finite-difference gradient |
| `cycle_linkage_energy.m` | Area, reflex-angle, and contact energy |
| `cycle_linkage_contact_energy.m` | Cycle-linkage contact energy |
| `cycle_linkage_combined_energy.m` | Weighted area/contact energy |
| `cycle_linkage_signed_area.m` | Signed enclosed area |
| `projected_cycle_linkage_gradient.m` | Projection onto the closure constraints |

## Scope

This module is a direct organizational refactor of the supplied implementation.
It does not change its energy formulas, constraint projection, update rule, or
termination tests.
