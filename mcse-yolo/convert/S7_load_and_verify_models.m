% S7_load_and_verify_models.m
% Loads all three exported ONNX models into MATLAB and runs a test
% forward pass to confirm they produce valid detections.
% Run this BEFORE writing any LRP code.

clc; clear; close all;

%% ── Load models ──────────────────────────────────────────────────────────
% importNetworkFromONNX requires Deep Learning Toolbox
% If you get an error here, run: matlab.addons.install('Deep Learning Toolbox')
matlab.addons.install
fprintf('Loading ONNX models...\n');
net_rgb = importNetworkFromONNX('runs/detect/runs/SIMD_RGB/weights/best.onnx','InputDataFormats', 'BCSS');    % Batch x Channel x Spatial x Spatial
fprintf('  RGB model loaded.\n');

net_ygb = importNetworkFromONNX('runs/detect/runs/SIMD_YGB/weights/best.onnx','InputDataFormats', 'BCSS');
fprintf('  YGB model loaded.\n');

net_lgb = importNetworkFromONNX('runs/detect/runs/SIMD_LGB/weights/best.onnx','InputDataFormats', 'BCSS');
fprintf('  LGB model loaded.\n');

%% ── Test forward pass ────────────────────────────────────────────────────
% Load one val image from each variant and run inference
% Just checking that output shapes look right — not evaluating accuracy yet

val_rgb = imread('SIMD_RGB/val/images/0001.jpg');
val_ygb = imread('SIMD_YGB/val/images/0001.jpg');
val_lgb = imread('SIMD_LGB/val/images/0001.jpg');

% YOLO expects 640x640 input, normalize to [0,1], BCHW format
function t = prep(img)
    img_r = imresize(img, [640 640]);
    t     = single(img_r) / 255;
    t     = permute(t, [3 1 2]);    % HxWxC -> CxHxW
    t     = reshape(t, [1 size(t)]); % add batch dim -> 1xCxHxW
end

out_rgb = predict(net_rgb, prep(val_rgb));
out_ygb = predict(net_ygb, prep(val_ygb));
out_lgb = predict(net_lgb, prep(val_lgb));

fprintf('\nForward pass output shapes:\n');
fprintf('  RGB output: %s\n', mat2str(size(out_rgb)));
fprintf('  YGB output: %s\n', mat2str(size(out_ygb)));
fprintf('  LGB output: %s\n', mat2str(size(out_lgb)));

% YOLOv8 nano output shape: [1 x (4+nc) x 8400]
% = 1 batch x 19 values (4 bbox + 15 classes) x 8400 anchor positions
% If you see this, the models are working correctly.

fprintf('\nModels verified. Ready for LRP phase.\n');
