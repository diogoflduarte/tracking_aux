function fileloc = lm_uigetfile(varargin)
% wrapper function for matlab's uigetfile, so that we have the full path

[FileName,PathName] = uigetfile(varargin{:});

if FileName == 0 
    fileloc = 0;
else
    fileloc = fullfile(PathName, FileName);
end

end