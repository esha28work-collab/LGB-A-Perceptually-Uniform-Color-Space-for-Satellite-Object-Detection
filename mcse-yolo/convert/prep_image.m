% prep_image.m
% Prepares a raw SIMD image for YOLO inference and LRP.
%
% THEORY (DIP):
% YOLO was trained on 640x640 inputs normalized to [0,1].
% The network learned to interpret pixel values in that range.
% Feeding it 1024x768 uint8 values would produce garbage outputs.
%
% The permute step is critical:
%   MATLAB stores images as  H x W x C  (rows x cols x channels)
%   YOLO/ONNX expects input  C x H x W  (channels x rows x cols)
%   permute([3 1 2]) reorders the dimensions correctly.
%
% dlarray wraps the tensor so MATLAB can track gradients through it —
% this is what makes automatic differentiation (and therefore LRP) possible.
%
% Input:  img     — H x W x 3 uint8 image
% Output: dl_img  — dlarray, shape [1 x 3 x 640 x 640], 'BCSS' format

function dl_img = prep_image(img)
    img_r   = imresize(img, [640 640]);          % resize to YOLO input size
    img_f   = single(img_r) / 255;              % uint8 [0,255] → single [0,1]
    img_p   = permute(img_f, [3 1 2]);           % HxWxC → CxHxW
    img_b   = reshape(img_p, [1 size(img_p)]);   % CxHxW → 1xCxHxW (add batch dim)
    dl_img  = dlarray(img_b, 'BCSS');            % wrap in dlarray for autodiff
end