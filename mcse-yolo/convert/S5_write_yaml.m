% S5_write_yaml.m
% Generates data.yaml for each of the three SIMD variants.
% These files tell YOLOv8 where to find images and what classes exist.

clc; clear;

variants = {'SIMD_RGB', 'SIMD_YGB', 'SIMD_LGB'};

class_names = {'car', 'truck', 'van', 'longvehicle', 'bus', ...
    'airliner', 'propeller', 'trainer', 'chartered', 'fighter', ...
    'other', 'stairtruck', 'pushbacktruck', 'helicopter', 'boat'};

for v = 1:3
    vname    = variants{v};
    yaml_path = fullfile(vname, 'data.yaml');
    fid       = fopen(yaml_path, 'w');

    % Use absolute paths — avoids working-directory issues during training
    abs_path = fullfile(pwd, vname);

    fprintf(fid, 'train: %s/train/images\n', abs_path);
    fprintf(fid, 'val:   %s/val/images\n',   abs_path);
    fprintf(fid, 'nc: 15\n');
    fprintf(fid, 'names:\n');
    for c = 1:15
        fprintf(fid, '  - %s\n', class_names{c});
    end

    fclose(fid);
    fprintf('Written: %s\n', yaml_path);
end