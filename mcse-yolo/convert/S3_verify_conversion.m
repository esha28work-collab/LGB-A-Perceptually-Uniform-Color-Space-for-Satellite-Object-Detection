% S3_verify_conversions.m
% Visual and numerical verification of all three conversion functions.
% Run on a handful of SIMD images BEFORE building the full datasets.

clc; clear; close all;

% Create output folder for figures
output_dir = 'IEEE_Figures/';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

src_dir = 'SIMDfulldataset/train/images/';
files   = dir(fullfile(src_dir, '*.jpg'));

% Pick 3 images to check: one with many cars, one sparse, one mixed
check_idx = [1, round(numel(files)/2), numel(files)];

% Define image names for labeling
image_names = {'Dense Traffic', 'Mixed Scene', 'Sparse Scene'};

for k = 1:3
    img = imread(fullfile(src_dir, files(check_idx(k)).name));
    
    rgb = rgb_passthrough(img);
    ygb = rgb_to_ygb(img);
    lgb = rgb_to_lgb(img);
    
    % ── Figure A: Channel 1 comparison ───────────────────────────────────
    figA = figure('Name', sprintf('Sample %d — Channel 1 comparison', k), ...
                  'Color', 'white', 'Units', 'centimeters', 'Position', [2 2 25 10]);
    
    subplot(1,3,1); imshow(rgb(:,:,1));
    title('R channel (RGB)', 'FontSize', 10); axis off;
    
    subplot(1,3,2); imshow(ygb(:,:,1));
    title('Y channel (YGB)', 'FontSize', 10); axis off;
    
    subplot(1,3,3); imshow(lgb(:,:,1));
    title('L channel (LGB)', 'FontSize', 10); axis off;
    
    % Save Figure A
    filenameA = sprintf('%sChannel1_Comparison_%s.png', output_dir, image_names{k});
    exportgraphics(figA, filenameA, 'Resolution', 300, 'BackgroundColor', 'white');
    fprintf('Saved: %s\n', filenameA);
    
    % ── Figure B: Full reconstructed images ──────────────────────────────
    figB = figure('Name', sprintf('Sample %d — Full image comparison', k), ...
                  'Color', 'white', 'Units', 'centimeters', 'Position', [2 2 25 10]);
    
    subplot(1,3,1); imshow(rgb);  title('RGB (Passthrough)', 'FontSize', 10); axis off;
    subplot(1,3,2); imshow(ygb);  title('YGB Conversion', 'FontSize', 10); axis off;
    subplot(1,3,3); imshow(lgb);  title('LGB Conversion', 'FontSize', 10); axis off;
    
    % Save Figure B
    filenameB = sprintf('%sFullImage_Comparison_%s.png', output_dir, image_names{k});
    exportgraphics(figB, filenameB, 'Resolution', 300, 'BackgroundColor', 'white');
    fprintf('Saved: %s\n', filenameB);
    
    % ── Figure C: Channel 1 intensity histograms ─────────────────────────
    figC = figure('Name', sprintf('Sample %d — Ch1 histograms', k), ...
                  'Color', 'white', 'Units', 'centimeters', 'Position', [2 2 28 10]);
    
    subplot(1,3,1);
    histogram(double(rgb(:,:,1)), 'NumBins', 64, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'none');
    title('R Channel (RGB)', 'FontSize', 10); 
    xlabel('Intensity (0-255)', 'FontSize', 9); 
    ylabel('Pixel Count', 'FontSize', 9);
    grid on;
    
    subplot(1,3,2);
    histogram(double(ygb(:,:,1)), 'NumBins', 64, 'FaceColor', [0.3 0.4 0.8], 'EdgeColor', 'none');
    title('Y Channel (YGB)', 'FontSize', 10); 
    xlabel('Intensity (0-255)', 'FontSize', 9); 
    ylabel('Pixel Count', 'FontSize', 9);
    grid on;
    
    subplot(1,3,3);
    histogram(double(lgb(:,:,1)), 'NumBins', 64, 'FaceColor', [0.2 0.7 0.5], 'EdgeColor', 'none');
    title('L Channel (LGB)', 'FontSize', 10); 
    xlabel('Intensity (0-255)', 'FontSize', 9); 
    ylabel('Pixel Count', 'FontSize', 9);
    grid on;
    
    % Save Figure C
    filenameC = sprintf('%sHistogram_Comparison_%s.png', output_dir, image_names{k});
    exportgraphics(figC, filenameC, 'Resolution', 300, 'BackgroundColor', 'white');
    fprintf('Saved: %s\n', filenameC);
end

% ── Figure D: Combined 6-panel figure for IEEE paper (BEST FOR PUBLICATION) ──
fprintf('\n=== Creating combined 6-panel IEEE figure ===\n');

% Use the middle image (image 2) for the combined figure
k_mid = 2;
img_mid = imread(fullfile(src_dir, files(check_idx(k_mid)).name));
rgb_mid = rgb_passthrough(img_mid);
ygb_mid = rgb_to_ygb(img_mid);
lgb_mid = rgb_to_lgb(img_mid);

% Create the master figure
figMaster = figure('Name', 'IEEE 6-Panel Comparison Figure', ...
                   'Color', 'white', 'Units', 'centimeters', 'Position', [1 1 20 15]);

% Row 1: Original images (RGB, YGB, LGB)
subplot(2, 3, 1);
imshow(rgb_mid);
title('(a) RGB Passthrough', 'FontSize', 10, 'FontWeight', 'bold');
axis off;

subplot(2, 3, 2);
imshow(ygb_mid);
title('(b) YGB Conversion', 'FontSize', 10, 'FontWeight', 'bold');
axis off;


subplot(2, 3, 3);
imshow(lgb_mid);
title('(c) LGB Conversion', 'FontSize', 10, 'FontWeight', 'bold');
axis off;

% Row 2: Channel 1 views (R, Y, L channels)
subplot(2, 3, 4);
imshow(rgb_mid(:,:,1));
title('(d) R Channel', 'FontSize', 10, 'FontWeight', 'bold');
axis off;
colormap(subplot(2,3,4), 'gray');

subplot(2, 3, 5);
imshow(ygb_mid(:,:,1));
title('(e) Y Channel', 'FontSize', 10, 'FontWeight', 'bold');
axis off;
colormap(subplot(2,3,5), 'gray');

subplot(2, 3, 6);
imshow(lgb_mid(:,:,1));
title('(f) L Channel', 'FontSize', 10, 'FontWeight', 'bold');
axis off;
colormap(subplot(2,3,6), 'gray');

% Add overall figure label
sgtitle('Color Space Conversion Comparison on SIMD Dataset', 'FontSize', 12, 'FontWeight', 'bold');

% Save the master figure
filenameMaster = sprintf('%sIEEE_6Panel_Comparison.png', output_dir);
exportgraphics(figMaster, filenameMaster, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Saved: %s\n', filenameMaster);

% Also save as PDF vector format for best quality
filenameMasterPDF = sprintf('%sIEEE_6Panel_Comparison.pdf', output_dir);
exportgraphics(figMaster, filenameMasterPDF, 'ContentType', 'vector', 'BackgroundColor', 'white');
fprintf('Saved: %s (vector PDF)\n', filenameMasterPDF);

% ── Numerical summary ─────────────────────────────────────────────────────
fprintf('\n=== Channel 1 statistics across 3 sample images ===\n');
fprintf('%-12s  %-10s  %-10s  %-10s\n', 'Scene Type', 'R mean', 'Y mean', 'L mean');
fprintf('%-12s  %-10s  %-10s  %-10s\n', '----------', '----------', '----------', '----------');

for k = 1:3
    img = imread(fullfile(src_dir, files(check_idx(k)).name));
    ygb = rgb_to_ygb(img);
    lgb = rgb_to_lgb(img);
    fprintf('%-12s  %-8.1f    %-8.1f    %-8.1f\n', image_names{k}, ...
        mean2(img(:,:,1)), mean2(ygb(:,:,1)), mean2(lgb(:,:,1)));
end

% ── Additional: Save histogram comparison as a single figure for paper ───
fprintf('\n=== Creating combined histogram figure ===\n');

figHist = figure('Name', 'Histogram Comparison', ...
                 'Color', 'white', 'Units', 'centimeters', 'Position', [2 2 25 10]);

% Use image 2 for histograms
img_hist = imread(fullfile(src_dir, files(check_idx(2)).name));
rgb_hist = rgb_passthrough(img_hist);
ygb_hist = rgb_to_ygb(img_hist);
lgb_hist = rgb_to_lgb(img_hist);

subplot(1,3,1);
histogram(double(rgb_hist(:,:,1)), 64, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'none');
title('R Distribution (RGB)', 'FontSize', 10);
xlabel('Intensity', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
xlim([0 255]);
grid on;

subplot(1,3,2);
histogram(double(ygb_hist(:,:,1)), 64, 'FaceColor', [0.3 0.4 0.8], 'EdgeColor', 'none');
title('Y Distribution (YGB)', 'FontSize', 10);
xlabel('Intensity', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
xlim([0 255]);
grid on;

subplot(1,3,3);
histogram(double(lgb_hist(:,:,1)), 64, 'FaceColor', [0.2 0.7 0.5], 'EdgeColor', 'none');
title('L Distribution (LGB)', 'FontSize', 10);
xlabel('Intensity', 'FontSize', 9);
ylabel('Frequency', 'FontSize', 9);
xlim([0 255]);
grid on;

sgtitle('Channel Intensity Distribution Comparison', 'FontSize', 11, 'FontWeight', 'bold');

filenameHist = sprintf('%sCombined_Histograms.png', output_dir);
exportgraphics(figHist, filenameHist, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Saved: %s\n', filenameHist);

fprintf('\n=== ALL FIGURES SAVED SUCCESSFULLY ===\n');
fprintf('Output directory: %s\n', output_dir);
fprintf('Total files saved: %d\n', (3*3) + 2); % 9 individual + 2 combined = 11 files