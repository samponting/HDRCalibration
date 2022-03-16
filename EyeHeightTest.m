%% Eye Height Check
     clc;
clear;
close;
sca;
% Initialise PTB and HDR 
PsychImaging('PrepareConfiguration');
dp = load('profile_cambridge_latest');
hdrh = hdrd_initialize(dp,{'do_tex_dlp',true,'dense_grid',true,'dlp_blur',2,'do_3dlut',false});


r = 30;
n = hdrh.height;
X = repmat(linspace(-hdrh.width,hdrh.width,n), n, 1);
Y = rot90(X);
C = X.^2 + Y.^2 <= r^2;
pattern1 = hdrh.peak_luminance*C;

pattern_tex1 = Screen('MakeTexture',hdrh.screen_win,double(pattern1),0,0,2);
backlight_tex1 = Screen('MakeTexture', hdrh.screen_win,double(max(pattern1,[],3)),0,0,2);

lum = [];
for i = 1:500

    Screen('DrawTexture',hdrh.tex, pattern_tex1,[],hdrh.rect);
    Screen('DrawTexture',hdrh.tex_dlp, backlight_tex1,[],hdrh.rect);
    hdrd_render(hdrh);
    hdrh = hdrd_flip(hdrh);
    KbWait;  
   
    pattern = ones([hdrh.width,hdrh.height])*500;
    pattern_tex = Screen('MakeTexture',hdrh.screen_win,double(pattern),0,0,2);
    backlight_tex = Screen('MakeTexture', hdrh.screen_win,double(max(pattern,[],3)),0,0,2);
    Screen('DrawTexture',hdrh.tex, pattern_tex,[],hdrh.rect);
    Screen('DrawTexture',hdrh.tex_dlp, backlight_tex,[],hdrh.rect);
    hdrd_render(hdrh);
    hdrh = hdrd_flip(hdrh);
    pause(3)
    lum(i) = specbos_measure();
    disp(num2str(lum(i)))
    

end