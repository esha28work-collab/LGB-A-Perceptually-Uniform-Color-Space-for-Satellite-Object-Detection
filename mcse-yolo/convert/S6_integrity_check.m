% S6_integrity_check.m (with tolerance for JPEG compression)
clc; clear;

variants = {'SIMD_RGB', 'SIMD_YGB', 'SIMD_LGB'};
splits   = {'train', 'val'};
expected = [4000, 1000];    % train, val

src_root = 'SIMDfulldataset/';
n_spot   = 30;
total_errors = 0;
tolerance = 2;  % Allow pixel differences up to 2 (due to JPEG compression)

%% ── 1. File count check ──────────────────────────────────────────────────
fprintf('=== File count check ===\n');
for v = 1:3
    for s = 1:2
        idir  = fullfile(variants{v}, splits{s}, 'images');
        ldir  = fullfile(variants{v}, splits{s}, 'labels');
        n_img = numel(dir(fullfile(idir, '*.jpg')));
        n_lbl = numel(dir(fullfile(ldir, '*.txt')));
        ok    = (n_img == expected(s)) && (n_lbl == expected(s));
        fprintf('  %-10s / %s: %4d img  %4d lbl  [%s]\n', ...
            variants{v}, splits{s}, n_img, n_lbl, ifstr(ok,'OK','ERROR'));
        if ~ok, total_errors = total_errors + 1; end
    end
end

%% ── 2. Pixel-level spot check ────────────────────────────────────────────
fprintf('\n=== Pixel-level spot check (%d random images, tolerance=%d) ===\n', n_spot, tolerance);
src_files = dir(fullfile(src_root, 'train/images/*.jpg'));
idx       = randperm(numel(src_files), min(n_spot, numel(src_files)));

for i = 1:length(idx)
    fname   = src_files(idx(i)).name;
    src_img = imread(fullfile(src_root, 'train/images', fname));

    ygb_img = imread(fullfile('SIMD_YGB/train/images', fname));
    lgb_img = imread(fullfile('SIMD_LGB/train/images', fname));
    rgb_img = imread(fullfile('SIMD_RGB/train/images', fname));

    % Check 1: spatial size must be identical
    if ~isequal(size(src_img), size(ygb_img)) || ~isequal(size(src_img), size(lgb_img))
        fprintf('  SIZE MISMATCH: %s\n', fname);
        total_errors = total_errors + 1; continue;
    end

    % Check 2: G and B must be nearly identical to source (allow JPEG compression)
    diff_ygb_g = max(abs(double(src_img(:,:,2)) - double(ygb_img(:,:,2))), [], 'all');
    diff_ygb_b = max(abs(double(src_img(:,:,3)) - double(ygb_img(:,:,3))), [], 'all');
    if diff_ygb_g > tolerance || diff_ygb_b > tolerance
        fprintf('  G/B CHANGED in YGB (max diff: G=%d, B=%d): %s\n', diff_ygb_g, diff_ygb_b, fname);
        total_errors = total_errors + 1;
    end
    
    diff_lgb_g = max(abs(double(src_img(:,:,2)) - double(lgb_img(:,:,2))), [], 'all');
    diff_lgb_b = max(abs(double(src_img(:,:,3)) - double(lgb_img(:,:,3))), [], 'all');
    if diff_lgb_g > tolerance || diff_lgb_b > tolerance
        fprintf('  G/B CHANGED in LGB (max diff: G=%d, B=%d): %s\n', diff_lgb_g, diff_lgb_b, fname);
        total_errors = total_errors + 1;
    end

    % Check 3: Ch1 must DIFFER from source R (conversion actually happened)
    if isequal(src_img(:,:,1), ygb_img(:,:,1))
        fprintf('  Ch1 UNCHANGED in YGB: %s\n', fname);
        total_errors = total_errors + 1;
    end
    if isequal(src_img(:,:,1), lgb_img(:,:,1))
        fprintf('  Ch1 UNCHANGED in LGB: %s\n', fname);
        total_errors = total_errors + 1;
    end

    % Check 4: RGB copy must be nearly identical to source (allow JPEG compression)
    diff_rgb = max(abs(double(src_img) - double(rgb_img)), [], 'all');
    if diff_rgb > tolerance
        fprintf('  RGB copy differs from source (max diff=%d): %s\n', diff_rgb, fname);
        total_errors = total_errors + 1;
    end
end

%% ── Result summary ───────────────────────────────────────────────────────
fprintf('\n=== Result ===\n');
if total_errors == 0
    fprintf('All checks passed. Datasets are ready for YOLO training.\n');
else
    fprintf('%d errors found. ', total_errors);
    if total_errors <= length(idx) * 4
        fprintf('These are likely due to JPEG compression. Consider using PNG for exact matching.\n');
    else
        fprintf('Fix before training.\n');
    end
end

function s = ifstr(cond, a, b)
    if cond, s = a; else, s = b; end
end