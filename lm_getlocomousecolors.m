function PointColors = lm_getlocomousecolors()
locohome = fileparts(fileparts(which('LocoMouse_DisplayTracks')));
a = load(fullfile(locohome,'LocoMouse_GlobalSettings','colorscheme.mat'));
PointColors = a.PointColors;
end