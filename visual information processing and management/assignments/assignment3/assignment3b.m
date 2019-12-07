clear all;
close all;

template = im2double(imread('images/stapleRemover.jpg'));
sceneImage = im2double(imread('images/clutteredDesk.jpg'));

%% Sliding window
% Image cropping

figure(1), clf
imshow(template)
template = imcrop(template);
best_max=0;
for scale=0.1:0.1:0.5
    resized_template = imresize(template, scale);
%     if rem(size(resized_template, 1), 2) == 0
%        resized_template = [resized_template; resized_template(end, :)]; 
%     end
%     if rem(size(resized_template, 2), 2) == 0
%        resized_template = [resized_template resized_template(:, end)]; 
%     end
%     pad_size = (size(resized_template) - 1) / 2;
%     padded_image = padarray(sceneImage, pad_size, 'replicate');
%     resized_template = resized_template - mean2(resized_template);
%     SAD_im = imfilter(sceneImage,resized_template,'replicate','same','corr');
%     [m n] = max(mat2gray(SAD_im(:)));
%     [x y z] = ind2sub(size(mat2gray(SAD_im)),n);
%     r = 30;
%     th = 0:pi/50:2*pi;
%     xunit = r * cos(th) + x;
%     yunit = r * sin(th) + y;
%     for row=pad_size(1):size(padded_image, 1)-pad_size(1)-1
%         for col=pad_size(2):size(padded_image, 2)-pad_size(2)-1
% %             row-pad_size(1)+1, col-pad_size(2)+1
% %             size(padded_image(row-pad_size(1)+1:row+pad_size(1)+1, col-pad_size(2)+1:col+pad_size(2)+1))
% %             sum(sum(abs(padded_image(row-pad_size(1)+1:row+pad_size(1)+1, col-pad_size(2)+1:col+pad_size(2)+1) - resized_template)))
% %             SAD_im(row-pad_size(1)+1, col-pad_size(2)+1) = sum(sum(abs(padded_image(row-pad_size(1)+1:row+pad_size(1)+1, col-pad_size(2)+1:col+pad_size(2)+1) - resized_template)));
% %             corr_im(row-pad_size(1)+1, col-pad_size(2)+1) = corr2(padded_image(row-pad_size(1)+1:row+pad_size(1)+1, col-pad_size(2)+1:col+pad_size(2)+1),resized_template);
%             SAD = mean2(padded_image(row-pad_size(1)+1:row+pad_size(1)+1, col-pad_size(2)+1:col+pad_size(2)+1) - resized_template);
%             if best_min > SAD
%                best_min=SAD;
%                best_index=[row-pad_size(1) col-pad_size(2)];
%             end
%         end
%     end
    c = normxcorr2(resized_template,sceneImage);
    % figure, surf(c), shading flat
    m=max(c(:));
    if m>best_max
        best_max=m;
        best_scale=scale;
        [ypeak, xpeak] = find(c==m);
        yoffSet = ypeak-size(resized_template,1);
        xoffSet = xpeak-size(resized_template,2);
        % indexes_per_scale=[indexes_per_scale; best_index];
    end
end
figure
imshow(sceneImage), hold on;
imrect(gca, [xoffSet+1, yoffSet+1, size(resized_template,2), size(resized_template,1)]), hold off;