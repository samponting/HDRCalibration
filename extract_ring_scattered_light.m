%% GenerateCSV


ref = pfs_read_image([pwd,'/Results/LSFMTF_CustomHDRreference.exr']);
imshow(ref)
roi = drawrectangle;
cropDim = int32(roi.Position);
imCropped = ref(cropDim(2):cropDim(2)+cropDim(4),cropDim(1):cropDim(1)+cropDim(3),:);
refExp = 1/200;
meanPix = squeeze(mean(imCropped,1:2));
%corMeanPix = meanPix;
corMeanPix = meanPix./refExp;
L_ring = 969;
z = 1;

for i = 360:20:1000
    img = pfs_read_image([pwd,'/Results/LSFMTF_CustomHDR_radius',num2str(i),'.exr']);
    imCropped = img(cropDim(2):cropDim(2)+cropDim(4),cropDim(1):cropDim(1)+cropDim(3),:);
    imgExp = 15;
    meanPix = squeeze(mean(imCropped,1:2));
%    result(z,:) = meanPix;
    result(z,:) = meanPix./imgExp;
    d_end(z) = i;
    d_beg(z) = i-200;
    Y(z) = meanPix(2)./imgExp;
    z = z+1;    



end
% d_beg = d_beg';
% d_end = d_end';
% Y = Y';
t = table(d_beg',d_end',Y','VariableNames',{'d_beg','d_end','Y'});

writetable(t,'LSTMTFCustomHDR.csv','WriteVariableNames',true)