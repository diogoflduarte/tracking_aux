% define directory where the videos are
vids.dataDir = 'E:\DiogoDuarte\data\x2_imaging';

vids.list = ...
    {'OneLessLight_PinholeMax_VideoDimensionsAdjusted',...
     'OneLessLight_PinholeMax2_0_0_M_tied_0,000_0,000_1_10_b',...
     'OneLessLight_PinholeMax2_0_0_M_tied_0,000_0,000_1_11_b',...
     'PinholeMax_VideoDimensionsAdjusted',...
     'PinholeMedio_VideoDimensionsAdjusted',...
     'PinholeMin_VideoDimensionsAdjusted'};
vids.nV = numel(vids.list);

% make list of avi's with fullpath
for v=1:vids.nV
    vids.listAVI{v,1}= fullfile(vids.dataDir, strcat(vids.list{v},'.avi'));
    vids.listMP4{v,1}= fullfile(vids.dataDir, strcat(vids.list{v},'.mp4'));
end

%   convert to mp4
for v = 1:vids.nV
    % create black background
    lm_createBlackBackground( vids.listAVI{v} );
    
    %  rotate video and backgrond
    lm_rotateVideo( vids.listAVI{v} , 'rot', 'cclock');
    
    % convert to mp4
    lm_avi2mp4( vids.listAVI{v} );
    
    
    
end

