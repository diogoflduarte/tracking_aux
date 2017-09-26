function lm_displayBB(vid, config_file, calib_file)

vm = lm_getVideoFrames(vid);
calib = load(calib_file);
bb = lm_readBBvalsconfig_file(config_file);
dframerate = 330;
f = figure; 
set(f, 'CloseRequestFcn', @onclosefig);
keepPlaying = 1;

frames = size(vm,3)-1;
ii = 2;
im = imagesc(vm(:,:,ii));
axis image;
axis off;
colormap gray;


% verify if BB fits

% show it
rectangle('position', bb.side, 'edgecolor', 'g');
rectangle('position', bb.bottom, 'edgecolor', 'y');

% show split line
if calib.splot_line>size(vm,1)
    warndlg('incorrect split line');
else
    line([1 size(vm,2)],[calib.split_line calib.split_line], 'color', 'm');
end

for ii=2:frames
    if keepPlaying
        set(im, 'cdata', vm(:,:,ii));
        pause(1/dframerate); % default framerate
    else
        return;
    end
end


function onclosefig(src, evt)
keepPlaying = 0;
set(gcf, 'closerequestfcn', 'closereq');
close(f);
end

end