function lm_rotateVideo(vid)
% clockwise rotates a video 'vid' by 90 degrees and OVERWRITES the
% existing file. If there is a background .png file with the same name as
% 'vid', it is rotated and OVERWRITTEN as well. Use with caution.
%
% NOTES: you need to have the converter installed, if windows, under:
%        'C:\libav-x86_64-w64-mingw32-11.7\usr\bin'
%        or else just change the path
%
% USAGE:    lm_rotateVideo(vid, ang), 'vid' is a string and the file must
%                                     exist, and 'ang' must be a scalar
%
% Diogo Duarte (2017)

% ............  input checks  .............................................

if ~exist(vid, 'file')
    error('Video file not found in lm_rotateVideo.');
end

[p, name, ext] = fileparts(vid);

vid2 = fullfile(p, strcat(name, '_r', ext)); % dummy

% ............  rotate video using libav  .................................
if ispc
    cmd_bin =  'C:\libav-x86_64-w64-mingw32-11.7\usr\bin';
    conv_cmd = fullfile(cmd_bin, 'avconv');
    command = sprintf('%s -i %s -vf transpose=cclock %s -y', ...
                      conv_cmd, ...
                      vid, ...
                      vid2);
    % execute it
    status = system(command);
else
    disp('Platform not yet supported.');
end

% ............  rotate the background, if exists,and save  ..............
if ~isempty(p)
    background = fullfile(p, strcat(name, '.png'));
else
    background = strcat(name, '.png');
end

% does not rotate if video rot fails
if exist(background, 'file') && ~status 
    disp('Background exists. Rotating...');
    % read the image
    B = imread(background);
    B = imrotate(B, -90, 'nearest', 'loose');
    imwrite(B, background);
end

% ........... delete original video, change name of vid2 ..................

% for some reason this is not working

% delete(vid);
% pause(0.3);
% copyfile(vid2, vid);
% pause(0.3);
% delete(vid2);

end