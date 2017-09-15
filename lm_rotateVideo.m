function lm_rotateVideo(vid, varargin)
% clockwise rotates a video 'vid' by 90 degrees and OVERWRITES the
% existing file. If there is a background .png file with the same name as
% 'vid', it is rotated and OVERWRITTEN as well. Use with caution.
%
% NOTES: you need to have the converter installed, if windows, under:
%        'C:\libav-x86_64-w64-mingw32-11.7\usr\bin'
%        or else just change the path
%
% USAGE:    lm_rotateVideo(vid),      'vid' is a string and the file must
%                                     exist
%           lm_rotateVideo(vid, 'rot', 'clock')  [clockwise]
%           lm_rotateVideo(vid, 'rot', 'cclock') [counterclockwise,default]
%
% Diogo Duarte (2017)

% ............  input checks  .............................................

ip = inputParser; % for parsing name-variable inputs
ip.addParameter('rot',  'cclock', @isgoodrot);
parse(ip, varargin{:});
% make them simple vars again
rot = ip.Results.rot;

if ~exist(vid, 'file')
    error('Video file not found in lm_rotateVideo.');
end

[p, name, ext] = fileparts(vid);

vid2 = fullfile(p, strcat(name, '_r', ext)); % dummy

% ............  rotate video using matlab  ................................

% read original video (import to matlab)
vid_vr = VideoReader(vid);
vid_out = VideoWriter(vid2, 'Grayscale AVI');
open(vid_out);

% read original video and write transposed frame
while hasFrame(vid_vr)
    frameIM = im2uint8(readFrame(vid_vr));
    
    switch(rot)
        case 'cclock'
            writeVideo(vid_out, flipud(squeeze(frameIM(:,:,1))'));
        case 'clock'
            % I'm not too sure about this
            writeVideo(vid_out, fliplr(squeeze(frameIM(:,:,1))'));
    end
end
close(vid_out);
clear vid_vr;
delete(vid);
pause(0.1);
if ~exist(vid, 'file')
    movefile(vid2, vid);
end

% ............  rotate the background, if exists,and save  ..............
if ~isempty(p)
    background = fullfile(p, strcat(name, '.png'));
else
    background = strcat(name, '.png');
end

if exist(background, 'file')
    disp('Background exists. Rotating...');
    % read the image
    B = imread(background);
    B = imrotate(B, -90, 'nearest', 'loose');
    imwrite(B, background);
end

end

function grot = isgoodrot(rot)
if strcmp(rot, 'cclock') || strcmp(rot, 'clock')
    grot = 1;
else 
    grot = 0;
end
end