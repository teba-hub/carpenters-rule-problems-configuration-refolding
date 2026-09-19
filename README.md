# Planar Polygon Refolding by Energy Matching

MATLAB research code for continuously deforming one simple planar polygon
into another polygon with the same number of corresponding vertices. The
implementation balances vertex-to-vertex distance against a geometric energy
term that discourages vertex--edge contact.

This implementation accompanies the paper:

> Te Ba and Ze Zhou, "Morse theory and moduli spaces of self-avoiding
> polygonal linkages," arXiv:2506.06781, 2025.

Paper: [arXiv:2506.06781](https://arxiv.org/abs/2506.06781)

## Method

For a current polygon `x` and target polygon `p`, the implementation minimizes

```text
f(x) = d(x, p) + c [Phi(p) - Phi(x)]^2,
```

where `d` is the sum of distances between corresponding vertices, `Phi` is the
polygon contact energy, and `c` is the energy weight. The gradient is estimated
with forward finite differences and the polygon is updated by normalized
gradient descent with adaptive step size.

This repository preserves the original numerical method. The source cleanup,
English interface, and repository documentation do not alter its objective,
finite-difference rule, convergence test, or update sequence.

## Requirements

- MATLAB (tested with R2024b)
- No additional MATLAB toolboxes are required for the core computation

## Quick start

1. Open this directory in MATLAB.
2. Edit `refolding_config.m` if you want to change any settings.
3. Open `main.m`.
4. Run `main.m`.

With `config.generation.mode = 'mouse'`, select polygon vertices in boundary
order. The current input window spans `[-200, 100]` on both axes. With
`config.generation.mode = 'random'`, the program generates simple random
polygons.

During real-time visualization:

- Press **Space** to pause or resume.
- Press the **Left Arrow** to display a previously saved state while paused.

## Configuration

All intended user-adjustable settings are grouped in `refolding_config.m`.
The numerical defaults are unchanged.

### Polygon generation

| Parameter | Meaning | Current value |
| --- | --- | ---: |
| `config.n` | Number of polygon vertices | `12` |
| `config.generation.mode` | Input mode: `'mouse'` or `'random'` | `'mouse'` |
| `config.generation.mouse_x_limits` | Mouse-input x-axis range | `[-200, 100]` |
| `config.generation.mouse_y_limits` | Mouse-input y-axis range | `[-200, 100]` |
| `config.generation.random_max_attempts` | Maximum random-generation attempts | `100` |
| `config.generation.random_radius_min` | Minimum random radius | `0.3` |
| `config.generation.random_radius_max` | Maximum random radius | `1.0` |

### Optimization and real-time display

| Parameter | Meaning | Current value |
| --- | --- | ---: |
| `config.optimization.c` | Energy-matching weight | `0.1` |
| `config.optimization.step_size` | Initial gradient-descent step size | `0.1` |
| `config.optimization.max_iter` | Maximum number of iterations | `40000` |
| `config.optimization.tolerance` | Gradient-norm stopping tolerance | `1e-2` |
| `config.optimization.save_interval` | Interval between saved trajectory states | `1` |
| `config.optimization.verbose` | Print iteration information | `true` |
| `config.optimization.realtime_plot` | Enable real-time visualization | `true` |
| `config.optimization.plot_interval` | Interval between real-time plot updates | `2` |
| `config.optimization.save_video` | Record the real-time window | `false` |
| `config.optimization.video_filename` | Real-time video filename | `morphing.mp4` |
| `config.optimization.video_fps` | Real-time video frame rate | `30` |

### Output and replay

| Parameter | Meaning | Current value |
| --- | --- | ---: |
| `config.display.show_initial_comparison` | Show the input polygons | `true` |
| `config.display.show_objective_history` | Show linear and logarithmic objective plots | `true` |
| `config.display.show_final_comparison` | Show the final comparison | `true` |
| `config.summary.enabled` | Create the eight-panel summary | `true` |
| `config.summary.save_image` | Save the summary to disk | `false` |
| `config.summary.filename` | Summary image filename | `polygon_morphing_summary.png` |
| `config.summary.coverage` | Path fraction sampled by panels 1--7 | `0.80` |
| `config.replay.enabled` | Replay the saved trajectory | `false` |
| `config.replay.fps` | Replay frame rate | `30` |
| `config.replay.show_reference` | Show initial and target references | `true` |
| `config.replay.show_energy_plot` | Show the objective plot during replay | `true` |
| `config.replay.save_video` | Save the replay as a video | `false` |
| `config.replay.video_filename` | Replay video filename | `polygon_morphing_replay.mp4` |

## Source files

| File | Purpose |
| --- | --- |
| `main.m` | Minimal entry point for the demonstration |
| `refolding_config.m` | Contains all user-adjustable settings |
| `run_refolding_demo.m` | Coordinates input, optimization, and output |
| `get_polygon.m` | Accepts mouse input or generates a random simple polygon |
| `gradient_descent.m` | Implements the original optimization procedure |
| `objective_function.m` | Evaluates the distance-plus-energy objective |
| `compute_gradient.m` | Computes the forward finite-difference gradient |
| `compute_distance_d.m` | Computes corresponding-vertex distance |
| `compute_energy_phi.m` | Computes the polygon contact energy |
| `polygon_utils.m` | Provides geometric and plotting utilities |
| `visualize_morphing.m` | Replays a saved trajectory and optionally exports video |
| `generate_summary_image.m` | Creates an eight-panel trajectory summary |

## Assumptions and limitations

- Initial and target polygons must have the same number of vertices, with known
  vertex correspondence and consistent boundary order.
- Input polygons must be simple (non-self-intersecting).
- The first vertex is translated to the origin and the second is rotated onto
  the positive x-axis before optimization.
- This is research software: convergence is not guaranteed for every polygon
  pair or parameter choice.
- The contact energy becomes singular near exact vertex--edge contact.
- Real-time plotting can account for a substantial part of the running time.

## Citation

If this code contributes to your research, please cite the associated paper:

```bibtex
@misc{ba2025morse,
  title         = {Morse Theory and Moduli Spaces of Self-Avoiding Polygonal Linkages},
  author        = {Ba, Te and Zhou, Ze},
  year          = {2025},
  eprint        = {2506.06781},
  archivePrefix = {arXiv},
  primaryClass  = {math.CO},
  doi           = {10.48550/arXiv.2506.06781}
}
```

GitHub also recognizes the machine-readable citation metadata in
[`CITATION.cff`](CITATION.cff).

## Contact

- Maintainer: Te Ba
- Email: [batexu@hnu.edu.cn](mailto:batexu@hnu.edu.cn)
- GitHub: [teba-hub](https://github.com/teba-hub)
- Project repository: [Refolding_Problem](https://github.com/teba-hub/Refolding_Problem)

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
