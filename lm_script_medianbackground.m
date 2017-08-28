v = VideoReader(vid);
i = 1;
while hasFrame(v)
    video = readFrame(v);
    i = i+1;
end

%% make matrix

numFrames = length(video);

vm = zeros(v.Height, v.Width, 3, numFrames); % 3 for RGB channels

for ii = 1:numFrames
   vm(:,:,:,1) = video{1};
end

%% squeeze redudant third dimension

vm = squeeze(vm(:,:,1,:));  % now is height, width, time

%% 
vid='E:\DiogoDuarte\data\locomouse_debug\realtest_0_0___0,000_0,000_0_1_b_cropped_r.mp4';
v = VideoReader(vid);
vm = zeros(v.Height, v.Width, 3, numFrames); % 3 for RGB channels
ii = 1;
while hasFrame(v)
    video = readFrame(v);
    vm(:,:,:,ii) = video;
    ii = ii+1;
end

%% squeeze third dim

vms = squeeze(vm(:,:,1,:));

%% take median

m_vms = median(vms, 3);
figure; imagesc(m_vms);

%% give back third dimension so that R=G=B
m_vms3 = repmat(m_vms, 1,1,3);

imwrite(m_vms, gray, 'bck.png');

%% trying different encodings
m_vms_8 = uint8(m_vms);
m_vms_8(m_vms_8>63)=63;
imwrite(m_vms_8, gray, 'bck8.png');