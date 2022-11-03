clc;
clear;
close;
sca;
%cr = ColorRendererLinearRGB();
%cr = ColorRendererPQHDRDisplay('native');
cr = ColorRendererHDRDisplay();
screen_no = 1;
Screen('Preference', 'SkipSyncTests', 1);
cr = cr.init(screen_no);
luminance = 1000;
grad = 2;
X = repmat(linspace(1,cr.rect(3),cr.rect(3)),cr.rect(3),1);
Y = rot90(X);
stim = Y > X.*grad;
stim = stim(1:cr.rect(4),:);


pattern_tex1 = Screen('MakeTexture',cr.win,double(stim)*luminance,0,0,2);
Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect,[],0);
cr.render();
cr = cr.flip();