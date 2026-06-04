% S4_build_datasets.m (modified with debugging)
% Builds SIMD_RGB, SIMD_YGB, SIMD_LGB from SIMDfulldataset.

clc; clear;

%% ── Paths ────────────────────────────────────────────────────────────────
src_root = 'SIMDfulldataset/';
out_dirs = {'SIMD_RGB', 'SIMD_YGB', 'SIMD_LGB'};
splits   = {'train', 'val'};

%% ── Create all output folders ────────────────────────────────────────────
for d = 1:3
    for s = 1:2
        img_dir = fullfile(out_dirs{d}, splits{s}, 'images');
        lbl_dir = fullfile(out_dirs{d}, splits{s}, 'labels');
        if ~exist(img_dir,'dir'), mkdir(img_dir); end
        if ~exist(lbl_dir,'dir'), mkdir(lbl_dir); end
    end
end

%% ── Map variant index to conversion function ─────────────────────────────
convert_fns = {@rgb_passthrough, @rgb_to_ygb, @rgb_to_lgb};

%% ── Main conversion loop ─────────────────────────────────────────────────
for d = 1:3
    fn    = convert_fns{d};
    odir  = out_dirs{d};
    
    % Track errors for this variant
    gb_errors = 0;
    rgb_errors = 0;

    fprintf('\n[%s] Starting...\n', odir);

    for s = 1:2
        sp       = splits{s};
        src_idir = fullfile(src_root, sp, 'images');
        src_ldir = fullfile(src_root, sp, 'labels');
        dst_idir = fullfile(odir, sp, 'images');
        dst_ldir = fullfile(odir, sp, 'labels');

        img_files = dir(fullfile(src_idir, '*.jpg'));
        n         = numel(img_files);

        fprintf('  [%s / %s] %d images\n', odir, sp, n);
        tic;

        for i = 1:n
            fname = img_files(i).name;
            stem  = strrep(fname, '.jpg', '');

            % ── Convert and save image ────────────────────────────────────
            src_img = imread(fullfile(src_idir, fname));
            dst_img = fn(src_img);                    % apply conversion
            
            % ── DEBUGGING CHECKS ─────────────────────────────────────────
            if strcmp(odir, 'SIMD_RGB')
                % RGB must be IDENTICAL to source
                if ~isequal(src_img, dst_img)
                    if rgb_errors < 5
                        fprintf('    WARNING: RGB copy differs from source: %s\n', fname);
                    end
                    rgb_errors = rgb_errors + 1;
                end
            else  % YGB or LGB
                % G and B channels must be IDENTICAL to source
                if ~isequal(src_img(:,:,2), dst_img(:,:,2)) || ...
                   ~isequal(src_img(:,:,3), dst_img(:,:,3))
                    if gb_errors < 5
                        fprintf('    WARNING: G/B changed in %s: %s\n', odir, fname);
                    end
                    gb_errors = gb_errors + 1;
                end
            end
            
            imwrite(dst_img, fullfile(dst_idir, fname), 'Quality', 95);

            % ── Copy label ────────────────────────────────────────────────
            src_lbl = fullfile(src_ldir, [stem '.txt']);
            dst_lbl = fullfile(dst_ldir, [stem '.txt']);
            if isfile(src_lbl)
                copyfile(src_lbl, dst_lbl);
            end

            % Progress every 500 images
            if mod(i, 500) == 0
                elapsed = toc;
                eta     = elapsed / i * (n - i);
                fprintf('    %d/%d — %.1f img/s — ETA: %.0fs\n', ...
                    i, n, i/elapsed, eta);
            end
        end

        fprintf('  [%s / %s] Done in %.1fs — Errors: G/B=%d, RGB=%d\n', ...
            odir, sp, toc, gb_errors, rgb_errors);
    end

    fprintf('[%s] Complete. Total errors: G/B=%d, RGB=%d\n', odir, gb_errors, rgb_errors);
end

fprintf('\nAll three datasets built successfully.\n');