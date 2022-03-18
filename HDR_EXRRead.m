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
files = {'xy' '1' 'x2' 'x3' 'x4' 'x5' 'x6' };
for i = 1:6
    im = pfs_read_rgb(['/home/sjp243/HDRIMGS/img', files{i},'.exr']);

    pattern_tex1 = Screen('MakeTexture',cr.win,double(500*im),0,0,2);
    Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
    cr.render();
    cr = cr.flip();
    KbWait;
end
while(true)
    [keyIsDown, ~, keyCode, ~] = KbCheck();
    if strcmpi(KbName(keyCode),'escape')
        break
    end
end
sca;
 