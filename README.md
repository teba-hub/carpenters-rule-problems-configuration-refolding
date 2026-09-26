# Implementations for the Carpenter’s Rule Problem and Configuration Refolding

MATLAB computational implementations for two related planar deformation
problems: the fixed-length Carpenter’s Rule Problem and configuration refolding by
energy matching. The implementations are organized as separate modules
because they use different configuration spaces and do not impose the same
constraints.

## Modules

| Module | State variables | Fixed edge lengths | Included cases |
| --- | --- | --- | --- |
| `carpenters_rule_problem` | Segment directions with prescribed lengths | Yes | Arm linkages and cycle linkages |
| `configuration_refolding` | Cycle-linkage vertex coordinates | No | Energy-matching configuration refolding with dynamic energy weight |

The second module deforms vertex coordinates directly. It is related to
configuration refolding, but it is not a strict fixed-length linkage solver.

## Requirements

- MATLAB (tested with R2024b)
- No additional MATLAB toolbox is required for the core computations

## Quick start

### Carpenter’s Rule Problem

Open `matlab/carpenters_rule_problem` in MATLAB and run:

```matlab
run_carpenters_rule_problem
```

Click vertices in order, then use one of the following keys:

- **Enter**: run the arm-linkage deformation.
- **Space**: run the cycle-linkage deformation with the original energy.

During a deformation, press **Space** to pause or resume. All adjustable
parameters for this module are in `carpenters_rule_config.m`.

### Configuration Refolding

Open `matlab/configuration_refolding` in MATLAB and run:

```matlab
run_configuration_refolding
```

All adjustable parameters are in `configuration_refolding_config.m`. The
mouse-input window remains fixed at `[-120, 120]` on both axes by default.
Video export is optional and is disabled by default. To generate an MP4 after
optimization, set `config.video.enabled = true` in that configuration file.

## Repository layout

```text
matlab/
|-- carpenters_rule_problem/  Fixed-length arm and cycle linkages
`-- configuration_refolding/ Vertex-coordinate configuration refolding
tests/                      Lightweight numerical checks
```

Each module has its own README with its mathematical scope, controls, source
files, and limitations.

## Versioning

The current release is version `2.0.0`. The original standalone
configuration-refolding implementation is retained as version `1.0.0` in the
repository history. See [CHANGELOG.md](CHANGELOG.md) for release details and
compatibility notes.

## Testing

From the repository root, run the lightweight numerical checks in MATLAB:

```matlab
addpath('tests');
run_smoke_tests
```

## Numerical-method preservation

The integration reorganizes names, configuration, documentation, and plotting
only. The energy formulas, finite-difference rules, projected direction,
gradient-descent updates, line search, continuation rule, tolerances, stopping
conditions, and iteration order retain their source defaults.

## Associated paper

This software accompanies:

> Te Ba and Ze Zhou, "Morse theory and moduli spaces of self-avoiding
> polygonal linkages," arXiv:2506.06781, 2025.

[Paper on arXiv](https://arxiv.org/abs/2506.06781)

## Citation

If this code contributes to your research, cite the associated paper. GitHub
also recognizes the machine-readable metadata in `CITATION.cff`.

## License

This project is released under the MIT License. See `LICENSE`.
