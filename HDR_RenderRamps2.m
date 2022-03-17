fclose(instrfind);
clc;
clear;
close;
sca;

%cr = ColorRendererLinearRGB();
cr = ColorRendererPQHDRDisplay( 'native' );
%cr = ColorRendererHDRDisplay();

screen_no = 1;


KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);

cr = cr.init(screen_no);


r = 50;
n = 1000;
X = repmat(linspace(-cr.rect(3)/6,cr.rect(3)/6,n), n, 1);
Y = rot90(X);
C = X.^2 + Y.^2 <= r^2;
nc = 3;



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
%lumLevels = [0.01 0.025 0.1];
lumLevels = [0.25 1 2.5 10 25 100 250];
lum = 1;
col = 1;


pattern1 = 1000*repmat(C, nc, nc);
pattern_tex1 = Screen('MakeTexture',cr.win,double(pattern1),0,0,2);
for dot = 1:9
    % Draw textures in PTB
    Screen('DrawTexture',cr.draw_tex, pattern_tex1,[],cr.rect);

    cr.render();
    cr = cr.flip();
    KbWait;
    figure('NumberTitle','off','Name',['dot',num2str(dot)])
    for lum = 1:length(lumLevels)
        for col = 1:length(colors)
            disp([col ' ' lum])
            fill_color = colors(:,col).*lumLevels(lum);
            Screen('FillRect', cr.draw_tex, 10*fill_color);
            cr.render();
            cr = cr.flip();


            specbos_measure('COM5');
            [lambda, L] = specbos_get_sprad('COM5');
%             if lumLevels(lum) == .1
%                 lumLevels(lum) = '0point1';
%             elseif lumLevels(lum) == .25
%                 lumLevels(lum) = '0point25';
%             elseif lumLevels(lum) == 2.5
%                 lumLevels(lum) = '2point5';
%             end
            Sprad.(['dot',num2str(dot)]).(colName{col}).(['lum',num2str(lum)]) = L;
            if col < 7
                subplot(3,3,col)
            else
                subplot(3,3,col+1);hold on
            end
            plot(lambda,Sprad.(['dot',num2str(dot)]).(colName{col}).(['lum',num2str(lum)]));hold on
            title(colName{col})


        end
    end
end
sca;