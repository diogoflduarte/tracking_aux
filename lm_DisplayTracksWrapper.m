function lm_DisplayTracksWrapper(vidDir, vidName, outputDir)
% wrapper function so that I can visualize results (with
% LocoMouse_DisplayTracks)
% lm_DisplayTracksWrapper(vid_name)
%
% assumes there is a background file in .png format in the same location as
% the video (.avi) file
% 
% INPUTS:
%   vidDir: directory where video and background are
%   vidName: video name without the extension
%   outputDir: as specified in LocoMouse_Tracker (w/ subfolders 'data' and
%              images
% EXAMPLE:
%   vidDir = 'E:\DiogoDuarte\data\locomouse_debug';
%   vidName = 'short';
%   outputDir = fullfile(vidDir, 'output');

% data output file resulting from the tracker
outFile = fullfile(outputDir, 'data', strcat(vidName, '.mat'));
% load it onto struct T
T = load(outFile);

% complete struct T with necessary stuff
T.data.vid = fullfile(vidDir, strcat(vidName, '.avi'));
T.data.bkg = fullfile(vidDir, strcat(vidName, '.png'));

% display results like you would using LocoMouse_DisplayTracks
LocoMouse_DisplayTracks({T.data,T.final_tracks,T.tracks_tail});
end