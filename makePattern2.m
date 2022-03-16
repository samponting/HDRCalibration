function [pattern] = makePattern(pnum, hi, lo, sz, v,hdrh)
    white = cat(3,0.95,1,1.08);
    maxpnum = 6;
    pnum = mod(pnum-1,maxpnum)+1;
    switch pnum
        case 1
            disp(['Uniform field: ' num2str(hi) ' cd/m2']);
            pattern = repmat(white*hi, [hdrh.height hdrh.width 1]);
        case 2
            pattern = repmat(white*lo, [hdrh.height hdrh.width 1]);
            v = mod(v, 3);
            if v==0
                disp(['Lines: horizontal, ' num2str(sz) 'px apart, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern((sz/2):sz:end, :, :) = repmat(white*hi, [floor(hdrh.height/sz) hdrh.width 1]);
            elseif v==1
                disp(['Lines: vertical, ' num2str(sz) 'px apart, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern(:, (sz/2):sz:end, :) = repmat(white*hi, [hdrh.height floor(hdrh.width/sz) 1]);
            else
                disp(['Lines: grid, ' num2str(sz) 'px apart, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern((sz/2):sz:end, :, :) = repmat(white*hi, [floor(hdrh.height/sz) hdrh.width 1]);
                pattern(:, (sz/2):sz:end, :) = repmat(white*hi, [hdrh.height floor(hdrh.width/sz) 1]);
            end
        case 3
            pattern = repmat(white*lo, round([hdrh.height/sz hdrh.width/sz 1]));
            pattern(1:2:end, 1:2:end, :) = repmat(white*hi, round([hdrh.height/sz/2 hdrh.width/sz/2 1]));
            v = mod(v, 3);
            if v==0
                disp(['Blocks: horizontal, ' num2str(sz) 'px wide, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern(1:2:end, 2:2:end, :) = repmat(white*hi, round([hdrh.height/sz/2 hdrh.width/sz/2 1]));
            elseif v==1
                disp(['Blocks: vertical, ' num2str(sz) 'px wide, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern(2:2:end, 1:2:end, :) = repmat(white*hi, round([hdrh.height/sz/2 hdrh.width/sz/2 1]));
            else
                disp(['Blocks: checkerboard, ' num2str(sz) 'px wide, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern(2:2:end, 2:2:end, :) = repmat(white*hi, round([hdrh.height/sz/2 hdrh.width/sz/2 1]));
            end
            pattern = imresize(pattern, sz, 'nearest');
        case 4
            pattern = repmat(white*lo, [hdrh.height hdrh.width 1]);
            v = mod(v, 2);
            w = log2(sz)/8 * 0.8 + 0.1;
            if v==0
                p = round(hdrh.height * w);
                disp(['Half: horizontal, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern(1:p, :, :) = repmat(white*hi, [p hdrh.width 1]);
            else
                p = round(hdrh.width * w);
                disp(['Half: vertical, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
                pattern(:, 1:p, :) = repmat(white*hi, [hdrh.height p 1]);
            end
        case 5 % Gradient
%            patternA = repmat(white*hi, [hdrh.height hdrh.width 1]);
%            patternB = repmat(, [hdrh.height hdrh.width 1]);
            v = mod(v, 2);
            if v==0
                disp(['Gradient: horizontal, from ' num2str(lo) ' to ' num2str(hi) ' cd/m2']);
                xx = logspace( log10(lo), log10(hi), hdrh.width);
                zz = zeros(size(xx));
                h4 = hdrh.height/4;
                pattern = cat( 1, repmat(xx, [h4 1 3]), ... % white
                       repmat( cat( 3, xx, zz, zz ), [h4 1 1] ), ... %red
                       repmat( cat( 3, zz, xx, zz ), [h4 1 1] ), ... % green
                       repmat( cat( 3, zz, zz, xx ), [h4 1 1] ) ); % blue
            else
                disp(['Gradient: vertical, from ' num2str(lo) ' to ' num2str(hi) ' cd/m2']);

                xx = logspace( log10(lo), log10(hi), hdrh.height)';
                zz = zeros(size(xx));
                w4 = hdrh.width/4;
                pattern = cat( 2, repmat(xx, [1 w4 3]), ... % white
                       repmat( cat( 3, xx, zz, zz ), [1 w4 1] ), ... %red
                       repmat( cat( 3, zz, xx, zz ), [1 w4 1] ), ... % green
                       repmat( cat( 3, zz, zz, xx ), [1 w4 1 1] ) ); % blue
                
            end
        case 6
            disp(['Circle: radius ' num2str(sz) 'px, ' num2str(hi) ' on ' num2str(lo) ' cd/m2']);
            pattern = repmat(white*lo, [hdrh.height hdrh.width 1]);
            [x,y] = meshgrid(linspace(-hdrh.width/2+1, hdrh.width/2, hdrh.width), linspace(-hdrh.height/2+1, hdrh.height/2, hdrh.height));
            mask = (x.^2+y.^2) < sz^2;
            pattern(repmat(mask, [1 1 3])) = reshape( repmat(white*hi, [nnz(mask) 1 1]), [nnz(mask)*3 1]);
    end
end