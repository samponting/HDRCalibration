clc;
clear;
close;
sca;
%cr = ColorRendererLinearRGB();
cr = ColorRendererPQHDRDisplay('native');
%cr = ColorRendererHDRDisplay();
screen_no = 1;
KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);
cr = cr.init(screen_no);

cr.rect = [0 0 3000 2000]; % Get rid of this!
r = 1/20;
n = 1000;
X = repmat(linspace(-cr.rect(3)/6,cr.rect(3)/6,n), n, 1);
Y = rot90(X);
C = X <= r*Y;
Stim = 100*C;% Edit this line!


Screen('DrawTexture',cr.draw_tex, Stim,[],cr.rect);
cr.render();
cr = cr.flip();

KbWait;
sca;


