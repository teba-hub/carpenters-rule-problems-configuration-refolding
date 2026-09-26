# Changelog

All notable changes to this project are documented in this file.

## [2.0.0] - 2026-09-26

### Added

- A fixed-length implementation of the Carpenter's Rule Problem for arm and
  cycle linkages.
- Separate MATLAB modules for the Carpenter's Rule Problem and Configuration
  Refolding.
- Centralized user-adjustable configuration files for both modules.
- Optional MP4 export for Configuration Refolding.
- Lightweight numerical smoke tests.

### Changed

- Expanded the project scope from the original refolding implementation to a
  unified research-code repository.
- Renamed the repository to
  `carpenters-rule-problems-configuration-refolding`.
- Standardized MATLAB file names, entry points, interface terminology, and
  visualization styling.
- Reorganized source files under `matlab/carpenters_rule_problem` and
  `matlab/configuration_refolding`.
- Updated the project documentation, citation metadata, and generated-output
  exclusions.

### Compatibility

- Version 2.0.0 changes the repository layout and MATLAB entry-point names.
- The underlying energy formulas, finite-difference rules, projected descent,
  line search, continuation rule, stopping criteria, and update order retain
  their source behavior.

## [1.0.0] - Legacy

### Added

- Initial public MATLAB implementation of planar configuration refolding by
  energy matching.
