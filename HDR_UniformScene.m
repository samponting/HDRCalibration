clear;
close;
sca;
clc;
% Initialise PTB and HDR 
PsychImaging('PrepareConfiguration');
dp = load('profile_cambridge_latest');
hdrh = hdrd_initialize(dp,{'do_tex_dlp',true,'dense_grid',true,'dlp_blur',2,'do_3dlut',false});

pnum = 1;
hi = 1000;
lo = 0;
sz = 32;
v = 0;
pattern = makePattern2(pnum, hi, lo, sz, v,hdrh);

pattern_tex = Screen('MakeTexture',hdrh.screen_win,double(pattern),0,0,2);
backlight_tex = Screen('MakeTexture', hdrh.screen_win,double(max(pattern,[],3)),0,0,2);
% Draw textures in PTB
Screen('DrawTexture',hdrh.tex, pattern_tex,[],hdrh.rect);
Screen('DrawTexture',hdrh.tex_dlp, backlight_tex,[],hdrh.rect);
hdrd_render(hdrh); 
hdrh = hdrd_flip(hdrh);
[keyIsDown, ~, keyCode, ~] = KbCheck();
if (strcmp(KbName(keyCode),'escape'))
    sca;
end