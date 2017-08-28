% script for rotating Hugo's files


%%   convert to mp4
vid='E:\DiogoDuarte\data\locomouse_debug\realtest_0_0___0,000_0,000_0_1_b.avi';
lm_avi2mp4(vid)

%%   create background
vidmp4 = 'E:\DiogoDuarte\data\locomouse_debug\realtest_0_0___0,000_0,000_0_1_b.mp4';
lm_createBlackBackground(vidmp4)

%%  rotate video and backgrond
lm_rotateVideo(vidmp4)