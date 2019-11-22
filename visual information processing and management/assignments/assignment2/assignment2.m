clear all;
close all;

flash = im2double(imread('giantShadowFlash.jpg'));
no_flash = im2double(imread('giantShadowNo-flash.jpg'));

figure(1), clf
hold on
subplot(1,2,1), imshow(flash), title('Flash image');
subplot(1,2,2), imshow(no_flash), title('No flash image');
hold off

figure(2), clf
hold on
imshow(flashPhotographyEnhancement(flash, no_flash, 'ycbcr', 'log'));
hold off

%% Function implementing the paper
% type of the rescaling: 'log' or ''
% intensity is how the intensity will be computed: 'non_linear' follow the
% paper implementation in the appendix; 'ycbcr' uses the Y channel
% from the YCbCr color space; 'hsv' uses the v channel from the hsv color;
% 'mean' takes simply the average of the RGB channels
function out=flashPhotographyEnhancement(flash, no_flash, intensity, rescaling)

    % Diagonal length
    diag_len = (size(flash, 1)^2 + size(flash, 2)^2)^0.5;

    %% Colour decoupling

    if strcmp(intensity,'non_linear')
        weights = flash ./ sum(flash, 3);

        I_f = sum(weights .* flash, 3);
        I_nf = sum(weights .* no_flash, 3);
    elseif strcmp(intensity,'ycbcr')
        I_f = rgb2ycbcr(flash);
        I_f = I_f(:, :, 1);

        I_nf = rgb2ycbcr(no_flash);
        I_nf = I_nf(:, :, 1);
    elseif strcmp(intensity,'hsv')
        I_f = rgb2hsv(flash);
        I_f = mat2gray(I_f(:, :, 3));

        I_nf = rgb2hsv(no_flash);
        I_nf = mat2gray(I_nf(:, :, 3));
    elseif strcmp(intensity,'mean')
        I_f = 1/3 * sum(flash, 3);
        I_nf = 1/3 * sum(no_flash, 3);
    end

    C_f = flash ./ I_f;
    % C_nf = no_flash ./ I_nf;

    %% Compute large scale images with a bilateral filtering

    if strcmp(rescaling,'log')
        c = 1 / log10(2);
        I_f = c .* log10(I_f + 1);
        I_nf = c .* log10(I_nf + 1);
        
%         LS_f = bfilter2(I_f, 1, [0.015 * diag_len 0.4]);
%         LS_nf = bfilter2(I_nf, 1, [0.015 * diag_len 0.4]);
%          
%         LS_f = imbilatfilt(I_f, 0.4, 0.015 * diag_len);
%         LS_nf = imbilatfilt(I_nf, 0.4, 0.015 * diag_len);
%         
        [ LS_f , ~ ]  =  shiftableBF(I_f, 0.015 * diag_len, 0.4);
        [ LS_nf , ~ ]  =  shiftableBF(I_nf, 0.015 * diag_len, 0.4);

        %% Compute details

        D_f = mat2gray(I_f - LS_f);
        
        %% Output
        
        out=C_f .* I_f .* mat2gray(D_f + LS_nf);
    elseif strcmp(rescaling,'')
%         LS_f = bfilter2(I_f, 1, [0.015 * diag_len 0.4]);
%         LS_nf = bfilter2(I_nf, 1, [0.015 * diag_len 0.4]);
%          
%         LS_f = imbilatfilt(I_f, 0.4, 0.015 * diag_len);
%         LS_nf = imbilatfilt(I_nf, 0.4, 0.015 * diag_len);
%         
        [ LS_f , ~ ]  =  shiftableBF(I_f, 0.015 * diag_len, 0.4);
        [ LS_nf , ~ ]  =  shiftableBF(I_nf, 0.015 * diag_len, 0.4);

        D_f = I_f ./ LS_f;
        
        %% Output
        
        out=C_f .* D_f .* LS_nf;
    end
end