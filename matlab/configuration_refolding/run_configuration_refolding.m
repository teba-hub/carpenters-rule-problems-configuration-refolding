% RUN_CONFIGURATION_REFOLDING Configure and run configuration refolding.
clear; clc; close all;

config = configuration_refolding_config();
results = execute_configuration_refolding(config);
