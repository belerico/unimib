clear all;
close all;

A = im2double(imread('images/eye.bmp'));
B = im2double(imread('images/hand.bmp'));
mask = im2double(imread('images/mask.bmp'));
blend = pyramidal_blending(A, B, mask, 10);
figure
subplot(1, 3, 1), imshow(A), title('Immagine 1')
subplot(1, 3, 2), imshow(B), title('Immagine 2')
subplot(1, 3, 3), imshow(blend), title('Immagine blendata')

function blend=pyramidal_blending(A, B, mask, levels)

%     if(isnumeric(mask))
%         [r, c] = size(mask, 1, 2);
%         if(r == 1 && c == 1)
%             % mask creation
%             left_size = round(size(A, 2) / 2 * mask);
%             mask = [ones(1, left_size) linspace(1, 0, size(A, 2) - 2 * left_size) zeros(1, left_size)];
%             mask = repmat(mask, size(A, 1), 1);
%         end
%     end
    
    GA = cell(levels);
    GA{1} = A;
    GB = cell(levels);
    GB{1} = B;
    GM = cell(levels);
    GM{1} = mask;
    LA = cell(levels - 1);
    LB = cell(levels - 1);
    sizes = cell(levels - 1);
    
    for lvl=2:levels
       GA{lvl} = impyramid(GA{lvl-1}, 'reduce');
       GB{lvl} = impyramid(GB{lvl-1}, 'reduce');
       GM{lvl} = impyramid(GM{lvl-1}, 'reduce');
       sizes{lvl-1} = size(GA{lvl-1}, 1, 2);
       LA{lvl-1} = GA{lvl-1} - imresize(GA{lvl}, sizes{lvl-1});
       LB{lvl-1} = GB{lvl-1} - imresize(GB{lvl}, sizes{lvl-1});
    end

    blend = GA{lvl} .* GM{lvl} + (1 - GM{lvl}) .* GB{lvl};
    lvl = lvl - 1;

    for lvl=lvl:-1:2
        blend = imresize(blend, sizes{lvl}) + LA{lvl} .* GM{lvl} + (1 - GM{lvl}) .* LB{lvl};
    end
end
