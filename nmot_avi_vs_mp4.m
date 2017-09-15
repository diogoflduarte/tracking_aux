function nmot_avi_vs_mp4( varargin )
% compares avi with mp4 trackings on the non motorized treadmill setup
% don't forget to specify your data path previously if you'd like to run
% this:
% nmot_avi_vs_mp4('datadir', wheremydatais)
%
% Diogo Duarte (2017)

% default data dir
datadir = 'E:\DiogoDuarte\data\x2_imaging\output_tracking';

% parse optional (changeable) datadir
ip = inputParser;
ip.addParameter('datadir', datadir, @isdir);
parse(ip, varargin{:});
datadir = ip.Results.ip;

% 
avidir = fullfile(datadir, 'avi', 'data'); % these don't actually contain 
mp4dir = fullfile(datadir, 'mp4', 'data'); % videos, but instead contain 
% the .mat files from the tracking

vids = {'OneLessLight_PinholeMax2_0_0_M_tied_0,000_0,000_1_10_b'    ,...
        'OneLessLight_PinholeMax2_0_0_M_tied_0,000_0,000_1_11_b'    ,...
        'OneLessLight_PinholeMax_VideoDimensionsAdjusted'           ,...
        'PinholeMax_VideoDimensionsAdjusted'                        ,...
        'PinholeMedio_VideoDimensionsAdjusted'                      ,...
        'PinholeMin_VideoDimensionsAdjusted'};

numvids = numel(vids);

for I=1:numvids
    % get tracks for avi
    aviT = fullfile(avidir, strcat(vids{I}, '.avi'));
    
    % get tracks for mp4
    mp4T = fullfile(avidir, strcat(vids{I}, '.mp4'));
    
    % plot them overlapping
    
    
    % calc dist matrix and show
    
end

end