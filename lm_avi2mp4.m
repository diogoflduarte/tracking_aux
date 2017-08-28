function lm_avi2mp4(vid)
% converts avi to mp4 by calling avconv from within matlab
% USAGE:
%   lm_avi2mp4(vid), where vid is a string with the video location.
%
% NOTES: you need to have the converter installed, if windows, under:
%        'C:\libav-x86_64-w64-mingw32-11.7\usr\bin'
%        or else just change the path
%
% Diogo Duarte (2017)

if ~exist(vid, 'file')
    error('Video file not found in lm_avi2mp4.');
end

if ispc
    cmd_bin =  'C:\libav-x86_64-w64-mingw32-11.7\usr\bin';
    conv_cmd = fullfile(cmd_bin, 'avconv');
    
    % build mp4 video file name
    vidmp4 = buildmp4name(vid);
    
    command = sprintf('%s -i %s -c:v libx264 -c:a copy %s', ...
                      conv_cmd, ...
                      vid, ...
                      vidmp4);
    
    % execute it
    status = system(command);
    
    if status==0
        disp('Conversion finished successfully');
    else
        disp('Something went wrong during conversion!');
    end
    
else
    disp('Platform not yet supported.');
end



end

function vidmp4 = buildmp4name(vid)
% builds mp4 filename from .avi file name (given as input)
[p, name, ~] = fileparts(vid);
if ~isempty(p)
    vidmp4 = fullfile(p, strcat(name, '.mp4'));
else
    vidmp4 = strcat(name, '.mp4');
end

end