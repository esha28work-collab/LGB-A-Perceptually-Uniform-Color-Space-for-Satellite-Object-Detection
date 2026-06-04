% S8_load_models.m
% Loads all three ONNX models and confirms forward pass works.
% This is your starting point for all LRP work.
%
% THEORY: importNetworkFromONNX brings the trained network weights
% into MATLAB's dlnetwork format, which supports automatic
% differentiation — the mathematical engine behind LRP.

clc; clear; close all;

base = 'C:\Users\HP ZBook 15 G7\Downloads\color\';

onnx_rgb = fullfile(base, 'runs\SIMD_RGB\weights\best.onnx');
onnx_ygb = fullfile(base, 'runs\SIMD_YGB\weights\best.onnx');
onnx_lgb = fullfile(base, 'runs\SIMD_LGB\weights\best.onnx');

fprintf('Loading models...\n');
net_rgb = importNetworkFromONNX(onnx_rgb, 'InputDataFormats','BCSS');
fprintf('  RGB loaded.\n');
net_ygb = importNetworkFromONNX(onnx_ygb, 'InputDataFormats','BCSS');
fprintf('  YGB loaded.\n');
net_lgb = importNetworkFromONNX(onnx_lgb, 'InputDataFormats','BCSS');
fprintf('  LGB loaded.\n');

% Save to workspace so other scripts can load without re-importing
save(fullfile(base, 'models.mat'), 'net_rgb', 'net_ygb', 'net_lgb');
fprintf('Models saved to models.mat\n');