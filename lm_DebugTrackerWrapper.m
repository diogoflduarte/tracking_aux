function lm_DebugTrackerWrapper(vid, outputDir)
% wrapper function for debugging tracks with debugTracker
% 
% lm_DebugTrackerWrapper(vid, outputDir)
%
% Diogo Duarte (2017)

[vidDir, vidName, ext] = fileparts(vid);

% data output file resulting from the tracker
dataFile = fullfile(outputDir, 'data', strcat(vidName, '.mat'));

% load it onto struct T
T = load(dataFile);

% location of the debug file
debugFile = fullfile(outputDir,strcat('debug_',vidName,'.yml'));
T.debug = importLocoMouseYAML(debugFile);

% complete struct T with necessary stuff
T.data.vid = fullfile(vidDir, strcat(vidName, ext));
T.data.bkg = fullfile(vidDir, strcat(vidName, '.png'));

% where's locomouse?
lm_installLoc = fileparts(fileparts(which('debugTracker')));

% if everything is in it's right place:
T.model = load(fullfile(lm_installLoc, 'LocoMouse_Tracker', ...
                            'model_files', 'model_LocoMouse_paper.mat'));

% final touches: add bounding box and occlusion grid to struct T
T.bounding_box = T.debug.bounding_box;
T.OcclusionGrid = T.debug.Occlusion_Grid_Bottom;

debugTracker({T,T.model,T.final_tracks,T.tracks_tail, T.OcclusionGrid, ...
    T.bounding_box,T.debug});

end