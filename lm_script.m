% script for rotating Hugo's files


%%   convert to mp4
vid='E:\DiogoDuarte\data\locomouse_debug\realtest_0_0___0,000_0,000_0_1_b_cropped.avi';
lm_avi2mp4(vid)

%%   create background
vidmp4 = 'E:\DiogoDuarte\data\locomouse_debug\realtest_0_0___0,000_0,000_0_1_b_cropped.mp4';
lm_createBlackBackground(vidmp4)

%%  rotate video and backgrond
lm_rotateVideo(vidmp4)

%% build calibration file (dummy calib)

% get video dimensions
lmVid = VideoReader(vidmp4);
vidInfo = get(lmVid);

width = vidInfo.Width;
height = vidInfo.Height;

% build calibration structure fields
matrix = zeros(height,width);
matrix(:) =  1:(height*width);
ind_warp_mapping = matrix;
inv_ind_warp_mapping = matrix;