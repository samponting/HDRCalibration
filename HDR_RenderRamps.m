%% HDR measurement ramps
% Initialise Workspace
% if exist('hdrh','var')
%     fclose(instrfind);
% end
clc;
clear;
close;
sca;
% Initialise PTB and HDR 
PsychImaging('PrepareConfiguration');
dp = load('profile_cambridge_latest');
hdrh = hdrd_initialize(dp,{'do_tex_dlp',true,'dense_grid',true,'dlp_blur',2,'do_3dlut',false});
 
%% Prep

% Color settings
grey = [1 1 1];
red = [1 0 0];
green = [0 1 0];
blue = [0 0 1]; 
magenta = [1 0 1];
yellow = [1 1 0];
cyan = [0 1 1];
colors = [red', green', blue', magenta', yellow', cyan', grey'];
colName = {'red','green','blue','magenta','yellow','cyan','grey'};

% Luminance settings 
lumLevels = [10 25 100 250 1000 2500];
%lumLevels = [10 25 100];

% Initialised stimulus array
baseArray = ones([hdrh.rect(3),hdrh.rect(4),3]);

r = 50;
n = 1000;
X = repmat(linspace(-hdrh.width/6,hdrh.width/6,n), n, 1);
Y = rot90(X);
C = X.^2 + Y.^2 <= r^2;
nc = 3;
pattern = hdrh.peak_luminance*repmat(C, nc, nc);

%% Experimental Loop 

% Loops across all colors at each luminance level
gridSize = 3;
numDots = gridSize^2;
for dot = 4
    r = 50;
    n = 1000;
    X = repmat(linspace(-hdrh.width/6,hdrh.width/6,n), n, 1);
    Y = rot90(X);
    C = X.^2 + Y.^2 <= r^2;
    nc = 3;
    pattern1 = hdrh.peak_luminance*repmat(C, nc, nc);
    pattern_tex1 = Screen('MakeTexture',hdrh.screen_win,double(pattern1),0,0,2);
    backlight_tex1 = Screen('MakeTexture', hdrh.screen_win,double(max(pattern1,[],3)),0,0,2);
    % Draw textures in PTB
    Screen('DrawTexture',hdrh.tex, pattern_tex1,[],hdrh.rect);
    Screen('DrawTexture',hdrh.tex_dlp, backlight_tex1,[],hdrh.rect);
    hdrd_render(hdrh);
    hdrh = hdrd_flip(hdrh);
    disp(['Point specbos to dot ',num2str(dot)])
    KbWait;
    figure('NumberTitle','off','Name',['dot',num2str(dot)])
    for lum = 1:length(lumLevels)
        for col = 1:length(colors)
            % Set base stimulus to luminance level
            lumStim = baseArray*lumLevels(lum);
            % Set stimulus to desired color
            stim(:,:,1) = lumStim(:,:,1)*colors(1,col);
            stim(:,:,2) = lumStim(:,:,2)*colors(2,col);
            stim(:,:,3) = lumStim(:,:,3)*colors(3,col);
            % Create PTB texture for both dlp and lcd
            pattern_tex = Screen('MakeTexture',hdrh.screen_win,double(stim),0,0,2);
            backlight_tex = Screen('MakeTexture',hdrh.screen_win,double(max(stim,[],3)),0,0,2);
            % Draw textures in PTB
            Screen('DrawTexture',hdrh.tex,pattern_tex,[],hdrh.rect);
            Screen('DrawTexture',hdrh.tex_dlp,backlight_tex,[],hdrh.rect);
            % Render to HDR
            hdrd_render(hdrh);
            hdrh = hdrd_flip(hdrh);

            % % WORKSPACE % %
            %to do: take measurements from specbos & save to a structure
            pause(5)
            specbos_measure();
            [lambda, L] = specbos_get_sprad();
            Sprad.(['dot',num2str(dot)]).(colName{col}).(['lum',num2str(lumLevels(lum))]) = L;
            if col < 7
                subplot(3,3,col)
            else
                subplot(3,3,col+1);hold on
            end
            plot(lambda,Sprad.(['dot',num2str(dot)]).(colName{col}).(['lum',num2str(lumLevels(lum))]));hold on
            title(colName{col})
            %KbWait;                                                  
        end
    end     
end
sca;

%save('lowlum,dot4.mat','Sprad')