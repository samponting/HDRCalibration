%LSFMTF
% clc;
% clear;
close all;
sca;

%cr = ColorRendererLinearRGB();
%cr = ColorRendererPQHDRDisplay('native');
cr = ColorRendererHDRDisplay();
screen_no = 1;
settings.screen_name = 'CustomHDR';
settings.viewing_distance = '92';
Screen('Preference', 'SkipSyncTests', 1);
cr = cr.init(screen_no);
luminance = 1000;
specbos = false;
if specbos == true
    bg = ones([cr.rect(4),cr.rect(3),3]);
    pattern_tex1 = Screen('MakeTexture',cr.win,double(bg)*luminance,0,0,2);
    Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
    cr.render();
    cr = cr.flip();
    settings.ring_lum = specbos_measure;
    KbWait;
end    
bg = zeros([cr.rect(4),cr.rect(3),3]);
x = cr.rect(3)/2;
y = cr.rect(4)/2;
bg(:,x-1:x+1) = 1;
bg(y-1:y+1,:) = 1;
pattern_tex1 = Screen('MakeTexture',cr.win,double(bg)*luminance,0,0,2);
Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
cr.render();
cr = cr.flip();
go = true;
if ~exist("xCen",'var')
    while(go == true)
        ListenChar(2)
        [keyIsDown, ~, keyCode, ~] = KbCheck();
        if strcmpi(KbName(keyCode),'escape')
            break
        elseif strcmpi(KbName(keyCode),'Left')
            pause(0.2)
            bg = zeros([cr.rect(4),cr.rect(3)]);
            x = x - 3;
            bg(:,x-1:x+1) = 1;
            bg(y-1:y+1,:) = 1;
            pattern_tex1 = Screen('MakeTexture',cr.win,double(bg)*luminance,0,0,2);
            Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
            cr.render();
            cr = cr.flip();
        elseif strcmpi(KbName(keyCode),'Right')
            pause(0.2)
            bg = zeros([cr.rect(4),cr.rect(3)]);
            x = x + 3;
            bg(:,x-1:x+1) = 1;
            bg(y-1:y+1,:) = 1;
            pattern_tex1 = Screen('MakeTexture',cr.win,double(bg)*luminance,0,0,2);
            Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
            cr.render();
            cr = cr.flip();
        elseif strcmpi(KbName(keyCode),'Down')
            pause(0.2)
            bg = zeros([cr.rect(4),cr.rect(3)]);
            y = y + 3;
            bg(:,x-1:x+1) = 1;
            bg(y-1:y+1,:) = 1;
            pattern_tex1 = Screen('MakeTexture',cr.win,double(bg)*luminance,0,0,2);
            Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
            cr.render();
            cr = cr.flip();
        elseif strcmpi(KbName(keyCode),'Up')
            pause(0.2) 
            bg = zeros([cr.rect(4),cr.rect(3)]);
            y = y - 3;
            bg(:,x-1:x+1) = 1;
            bg(y-1:y+1,:) = 1;
            pattern_tex1 = Screen('MakeTexture',cr.win,double(bg)*luminance,0,0,2);
            Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
            cr.render();
            cr = cr.flip();
        elseif strcmpi(KbName(keyCode),'Space')
            go = false;
            xCen = x;
            yCen = y;
        end
    end
end

dim = [cr.rect(3) cr.rect(4)];
settings.screen_res = dim;
grad = 2;
X = repmat(linspace(-dim(1)/2,dim(1)/2,dim(1)),dim(1),1);
Y = rot90(X);
ringwidth = 200;
settings.ring_width = ringwidth;
% bigRingDi = 100;
% outRing = (bigRingDi^2 >= (X-X(1,xCen)).^2 + (Y-Y(yCen,1)).^2)+1;
% inRing = ((bigRingDi-ringwidth)^2 >= (X-X(1,xCen)).^2 + (Y-Y(yCen,1)).^2)+1;
% added = outRing + inRing;
% stim = mod(added,2);
% buffer = (cr.rect(3) - cr.rect(4));
% stim = stim(1:end-buffer,:);
stim = ones([cr.rect(3),cr.rect(4),3]);
pattern_tex1 = Screen('MakeTexture',cr.win,double(stim)*luminance,0,0,2);
Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
cr.render();
cr = cr.flip();
disp('Ready. Connect camera. Press any button to continue')
KbWait;
gp = GPhoto;
out = pfs_exec('gphoto2 --set-config /main/capturesettings/f-number=4.5');
out = pfs_exec('gphoto2 --set-config /main/capturesettings/shutterspeed=1/200');
[gp,img] = gp.take_image();
imshow(img);
roi = drawrectangle;
cropDim = int32(roi.Position);
imCropped = img(cropDim(2):cropDim(2)+cropDim(4),cropDim(1):cropDim(1)+cropDim(3),:);
filename = cat(1,['LSFMTF_',settings.screen_name,'reference.exr']);
pfs_write_image([pwd,'/Results/',filename],imCropped)
z= 1;
for bigRingDi = 1000:-20:360
    outRing = (bigRingDi^2 >= (X-X(1,xCen)).^2 + (Y-Y(yCen,1)).^2)+1;
    inRing = ((bigRingDi-ringwidth)^2 >= (X-X(1,xCen)).^2 + (Y-Y(yCen,1)).^2)+1;
    added = outRing + inRing;
    stim = mod(added,2);
    buffer = (cr.rect(3) - cr.rect(4));
    stim = stim(1:end-buffer,:);
    pattern_tex1 = Screen('MakeTexture',cr.win,double(stim)*luminance,0,0,2);
    Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);
    cr.render();
    cr = cr.flip();
    out = pfs_exec('gphoto2 --set-config /main/capturesettings/shutterspeed=15');
    out = pfs_exec('gphoto2 --set-config /main/capturesettings/f-number=4.5');
    result(z).shutterspeed = '1';
    result(z).filename = cat(1,['LSFMTF_',settings.screen_name,'_radius',num2str(bigRingDi),'.exr']);
    [gp,img] = gp.take_image();
    imCropped = img(cropDim(2):cropDim(2)+cropDim(4),cropDim(1):cropDim(1)+cropDim(3),:);
    pfs_write_image([pwd,'/Results/',result(z).filename],imCropped)
%     pfsview(imCropped)
    pause(0.5)
    z = z+1;
end

save([pwd,'/Results/LSFMTF_CustomHDR_data.mat'],'settings','result')




