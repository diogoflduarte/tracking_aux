function lm_DisplayTracksWrapper(vid, outputDir)
% wrapper function so that I can visualize results (with
% LocoMouse_DisplayTracks)
% lm_DisplayTracksWrapper(vid_name, outputDir)
%
% assumes there is a background file in .png format in the same location as
% the video (.avi) file
% 
% INPUTS:
%   full path [IMPORTANT] to video
%   outputDir: as specified in LocoMouse_Tracker (w/ subfolders 'data' and
%              images
% EXAMPLE:
%   vid = 'E:\DiogoDuarte\data\locomouse_debug\short';
%   outputDir = fullfile(vid, 'output');
%
% Diogo Duarte (2017)

[vidDir, vidName, ext] = fileparts(vid);

if nargin<2
    outputDir = fullfile(vidDir, 'output_tracking');
end

% data output file resulting from the tracker
outFile = fullfile(outputDir, 'data', strcat(vidName, '.mat'));
% load it onto struct T
T = load(outFile);

% complete struct T with necessary stuff
T.data.vid = fullfile(vidDir, strcat(vidName, ext));
T.data.bkg = fullfile(vidDir, strcat(vidName, '.png'));

% display results like you would using LocoMouse_DisplayTracks
LocoMouse_DisplayTracksDD({T.data,T.final_tracks,T.tracks_tail});
end