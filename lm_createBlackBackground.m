function lm_createBlackBackground(vid)
% creates black background for a video vid in its location with the same
% size. format is .png
% USAGE:    lm_createBlackBackground(vid)
%
% Diogo Duarte (2017)

if ~exist(vid, 'file')
    error('Video file not found in lm_createBlackBackground.');
end

% ...........  get video name and path  ...................................
[p, name, ~] = fileparts(vid);

% ...........  make png file name  ........................................
if ~isempty(p)
    pngname = fullfile(p, strcat(name, '.png'));
else
    pngname = strcat(name, '.png');
end

% ...........  read video to get its dimensions  ..........................
lmVid = VideoReader(vid);
vidInfo = get(lmVid);

% x = vidInfo.Height;
% y = vidInfo.Width;
x = vidInfo.Width;
y = vidInfo.Height;

% ...........  make the image  ............................................
background_mat = zeros(y,x);

imwrite(background_mat, pngname);

end