function vm = lm_getVideoFrames(vid)
% reads video file and returns 4D (height, width, RBG, frames) matrix
%
% Diogo Duarte (2017)

% make video obj
v = VideoReader(vid);

video_read_start = tic;

% get numChannels
switch v.VideoFormat
    case 'RGB24'
        numChannels=3;
    case 'Grayscale'
        numChannels=1;
    otherwise
        error(strcat('For now, only RGB24 and Grayscale-encoded videos',...
                     ' are supported.'));
end

% get number of frames
numFrames = floor(v.FrameRate*v.Duration);

vm = zeros(v.Height, v.Width, numChannels, numFrames); % 3 for RGB channels

switch v.BitsPerPixel
    case 8
        vm = uint8(vm);
    case 24
        vm = uint8(vm);
    otherwise
        disp('Is this bitrate correct?');
        return;
end

ii = 1;

fprintf('Reading video file ... ');

while hasFrame(v)
    video = readFrame(v);
    vm(:,:,:,ii) = uint8(video);
    ii = ii+1;
end

vm = squeeze(mean(vm,3)); % suppress one channel
vm = uint8(vm); % force uint8 again....

fprintf(' Done. (%.1f s for reading)\n', toc(video_read_start) );

clear v;


end