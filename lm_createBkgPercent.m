function I=lm_createBkgPercent(vid, pc)
% get percentile of every pixel in video

v = VideoReader(vid);

I = zeros(v.Height, v.Width, floor(v.FrameRate*v.Duration));
I = uint8(I);
frameCounter = 1;
tmpF = [];

while hasFrame(v)
    switch v.VideoFormat
        case 'Grayscale'
            I(:,:,frameCounter) = readFrame(v);
        case 'RGB24'
            tmpF = readFrame(v);
            I(:,:,frameCounter) = squeeze(mean(tmpF,3));
        otherwise
            sprintf('Unknown format (%s)\n',mfilename);
            return;
    end
    
    frameCounter = frameCounter + 1;
end

bkg = prctile(I, pc, 3);

[p, name, ~] = fileparts(vid);

bkg_fname = fullfile(p, strcat(name, '.png'));
imwrite(bkg, bkg_fname);

end