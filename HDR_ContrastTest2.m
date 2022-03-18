fclose(instrfind);
clc;
clear;
close;
sca;
cr = ColorRendererPQHDRDisplay( 'native' );
%cr = ColorRendererHDRDisplay();
screen_no = 1;
cr = cr.init(screen_no);

levels = 550;

x = round(cr.rect(3)*3/4);
step = round(x/levels);
% lb = round(hdrh.width*1/3);
lb = 550; 

for loop = 1:levels
    disp(loop)
    pattern = zeros([cr.rect(4) cr.rect(3) 3]);
    p = round(lb + step*loop);
    pattern(:, 1:p, :) = 400*ones([cr.rect(4) p 3]);
    pattern_tex = Screen('MakeTexture',cr.win,double(pattern),0,0,2);
    Screen('DrawTexture',cr.draw_tex, pattern_tex,[],cr.rect);
    cr.render();
    cr = cr.flip();
    lum(loop) = specbos_measure('COM5');
    disp(num2str(lum(loop))) 
    Screen('Close')
    plot(lum);hold on
end


sca;