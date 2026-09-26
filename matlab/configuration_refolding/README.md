# Configuration Refolding Module

This module computes a continuous configuration refolding from one simple
planar cycle linkage toward a target cycle linkage with the same number of
corresponding vertices. It
minimizes

```text
f(x) = d(x, p) + c [Phi(p) - Phi(x)]^2,
```

where `d` is the sum of corresponding-vertex distances and `Phi` is the
polygon contact energy. The implementation includes monotone backtracking and
a dynamic reduction of `c` near a stalled endpoint.

This module optimizes vertex coordinates directly and does **not** impose
fixed edge-length constraints.

## Run

Open this directory in MATLAB and run:

```matlab
run_configuration_refolding
```

Edit `configuration_refolding_config.m` to change input, optimization,
visualization, and output settings. The important mouse-input defaults are
preserved:

```matlab
config.generation.mouse_x_limits = [-120, 120];
config.generation.mouse_y_limits = [-120, 120];
```

Video generation is an optional user setting in the same file. It is disabled
by default:

```matlab
config.video.enabled = false;  % Change to true to export an MP4
```

The video duration, frame rate, and filename are grouped directly below this
switch.

In the real-time window:

- **Space** pauses or resumes;
- **Left Arrow** displays a previous saved state while paused;
- **Esc** ends optimization normally and continues to the selected outputs.

## Main files

| File | Purpose |
| --- | --- |
| `run_configuration_refolding.m` | Public entry script |
| `configuration_refolding_config.m` | User-adjustable settings |
| `execute_configuration_refolding.m` | Input, optimization, and output workflow |
| `optimize_configuration_refolding.m` | Dynamic-`c` optimization procedure |
| `configuration_refolding_objective.m` | Distance-plus-energy objective |
| `configuration_refolding_gradient.m` | Forward finite-difference gradient |
| `configuration_contact_energy.m` | Polygon contact energy `Phi` |
| `corresponding_vertex_distance.m` | Corresponding-vertex distance term |
| `acquire_cycle_linkage.m` | Mouse or random cycle-linkage input |
| `export_configuration_refolding_video.m` | Optional fixed-duration MP4 export |
| `create_trajectory_summary.m` | Eight-state trajectory summary |
| `replay_configuration_trajectory.m` | Optional saved-trajectory replay |
| `polygon_geometry.m` | Shared polygon geometry and plotting operations |
| `resolve_plot_style.m` | Plot-style defaults and validation |

## Limitations

- Initial and target polygons must have the same number of vertices and known
  vertex correspondence.
- Input polygons must be simple.
- Convergence is not guaranteed for every polygon pair or parameter choice.
- The contact energy is singular near exact vertex-edge contact.

The numerical methods in this module retain the source implementation without
algorithmic changes.
