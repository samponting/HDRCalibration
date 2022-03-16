%% Contrast change measure

fclose(instrfind);      
clear;
close;
sca;
clc;
% Initialise PTB and HDR 
PsychImaging('PrepareConfiguration');
dp = load('profile_cambridge_latest');
hdrh = hdrd_initialize(dp,{'do_tex_dlp',true,'dense_grid',true,'dlp_blur',2,'do_3dlut',false});


%%


r = 10;
n = 1000;
X = repmat(linspace(-hdrh.width/6,hdrh.width/6,n), n, 1);
Y = rot90(X);
C = X.^2 + Y.^2 <= r^2;
%nc = 3;
pattern1 = hdrh.peak_luminance*C;
pattern_tex1 = Screen('MakeTexture',hdrh.screen_win,double(pattern1),0,0,2);
backlight_tex1 = Screen('MakeTexture', hdrh.screen_win,double(max(pattern1,[],3)),0,0,2);
% Draw textures in PTB
Screen('DrawTexture',hdrh.tex, pattern_tex1,[],hdrh.rect);
Screen('DrawTexture',hdrh.tex_dlp, backlight_tex1,[],hdrh.rect);
hdrd_render(hdrh); 
hdrh = hdrd_flip(hdrh);
KbWait;
levels = 280;

x = round(hdrh.width*3/4);
step = round(x/levels);
% lb = round(hdrh.width*1/3);
lb = 0; 

for loop = 1:levels
    disp(loop)
    pattern = zeros([hdrh.height hdrh.width 3]);
    p = round(lb + step*loop);
    pattern(:, 1:p, :) = 400*ones([hdrh.height p 3]);
    pattern_tex = Screen('MakeTexture',hdrh.screen_win,double(pattern),0,0,2);
    backlight_tex = Screen('MakeTexture', hdrh.screen_win,double(max(pattern,[],3)),0,0,2);
    Screen('DrawTexture',hdrh.tex, pattern_tex,[],hdrh.rect);
    Screen('DrawTexture',hdrh.tex_dlp, backlight_tex,[],hdrh.rect);
    hdrd_render(hdrh);
    hdrh = hdrd_flip(hdrh);
    lum(loop) = specbos_measure();
    disp(num2str(lum(loop))) 
    Screen('Close')
    plot(lum);hold on
end
















