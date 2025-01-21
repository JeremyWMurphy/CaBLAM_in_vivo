function [imgs] = read_tiff_stack(tif_nfo)
% read in a tiff stack, can be spread across multiple files, using
% tiffread2

imgs = [];
for j = 1:size(tif_nfo,1)
    [stack_tmp, ~] = tiffread2([tif_nfo(j).folder '\' tif_nfo(j).name]);
    w = stack_tmp.width;
    h = stack_tmp.height;
    stack_tmp = [stack_tmp(:).data];
    stack_tmp = reshape(stack_tmp,h,w,[]);
    stack_tmp = double(stack_tmp);
    imgs = cat(3,imgs,stack_tmp);
end