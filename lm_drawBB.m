function lm_drawBB(vid)
% draws bounding box and saves its limits onto the configuration yml file
% for locomouse
%
% Diogo Duarte (2017)

if nargin<1
    vid = lm_uigetfile({'*.avi;*.mp4'}, 'Select video file');
end

if vid==0
    % to avoid throwing out an error in case user selects "cancel"
    return;
end

% variables for counting if it's the first time something is being called
isFirstMouse = 1;
isFirstRect  = 1;
isFlipped    = 0;
% data line is Nlines after BB header in yml file:
Nlines = 4; % THIS IS IMPORTANT (and maybe not optimal)

% outputs
bb.sv_vals = [0 0 0 0];
bb.bv_vals = [0 0 0 0];

% kind of global vars so that every function can acces it
tbl_sv = [];% tables with rectangle values
tbl_bv = [];%
im = [];    % mouse image
tmpFrame = [];
% read video file
vm = lm_getVideoFrames(vid);

% get height and width
vdata.height = size(vm,1);
vdata.width  = size(vm,2);
vdata.nFrames = size(vm,4);

% make figure for showing mouse
% TODO: support for distortion (constrained vs non-constrained views)
[hh, ax] = make_mouseGUI(vdata);

% show the mouse
frame = 1;
update_mouseGUI(ax, vm, frame);

% buttons fr

% ask user to draw side view BB


    function get_mouseRect(src, evt, view)
%         display('btn pressed');
        rect = getrect(ax);
        switch view
            case 'side'
                bb.sv_vals = round(rect);
                updateRectangles('side');
            case 'bottom'
                bb.bv_vals = round(rect);
                updateRectangles('bottom');
        end
        updateBBvals(view);
    end
    function [hh, ax] = make_mouseGUI(vdata)
        % GUI for drawing bounding box
        
        mwh = 0.7; % maximum relative width or height inside figure
        
        hh = figure(); % will appear according with whatever matlab definitions are
        % in one computer
        
        % calculate width or height, depending on ratio
        vdata.ratio = vdata.width/vdata.height;
        if vdata.ratio <= 1
            % height is larger
            axHeight = mwh;
            axWidth = vdata.ratio*axHeight;
        else
            axWidth = mwh;
            axHeight = axWidth/vdata.ratio;
        end
        
        ax = axes('Parent', hh);
        set(ax,   ...
            'units', 'normalized', ...
            'position', [0.1    0.2    axWidth axHeight], ...
            'xtick', [], ...
            'ytick', []);
        
        % flip button
        flipbtn = uicontrol('style', 'pushbutton', 'parent', hh);
        set(flipbtn,    'units', 'normalized', ...
                        'position', [0.82 0.80 0.1 0.05], ...
                        'string', 'FLIP', ...
                        'callback', @flipFrame);
        
        % side view button
        bb_sv = uicontrol('style', 'pushbutton', 'parent', hh);
        set(bb_sv, 'units', 'normalized', ...
            'position', [0.82 0.65 0.1 0.05], ...
            'string', 'side v', ...
            'callback', {@get_mouseRect, 'side'});
        % bottom view bottom
        bb_bv = uicontrol('style', 'pushbutton', 'parent', hh);
        set(bb_bv, 'units', 'normalized', ...
            'position', [0.82 0.50 0.1 0.05], ...
            'string', 'bottom v', ...
            'callback', {@get_mouseRect, 'bottom'});
        
        % make table for showing values
        tbl_hdr = uicontrol('style', 'text', 'parent', hh);
        set(tbl_hdr,        'string', 'X Y W H', ...
                            'units', 'normalized', ...
                            'position', bb_sv.Position+[0 -0.05 0 0]);
        tbl_sv  = uicontrol('style', 'text', 'parent', hh);
        set(tbl_sv,         'string', num2str(bb.sv_vals), ...
                            'units', 'normalized', ...
                            'horizontalalignment', 'left', ...
                            'fontsize', 7, ...
                            'position', tbl_hdr.Position+[0 -0.04 0.06 0]);
        tbl_bv  = uicontrol('style', 'text', 'parent', hh);
        set(tbl_bv,         'string', num2str(bb.bv_vals), ...
                            'units', 'normalized', ...
                            'horizontalalignment', 'left', ...
                            'fontsize', 7, ...
                            'position', bb_bv.Position+[0 -0.05 0.06 0]);
                        
        save_btn = uicontrol('style', 'pushbutton', 'parent', hh);
        set(save_btn,   'units', 'normalized', ...
                        'position', [0.82 0.30 0.15 0.05], ...
                        'string', 'Save to YML', ...
                        'callback', {@save_to_yml});
                    
        % make slider
        slider_frames = uicontrol('style', 'slider', 'parent', hh);
        set(slider_frames,  'units', 'normalized', ...
                            'position', [0.1 0.05 0.5 0.03], ...
                            'string', '', ...
                            'callback', {@updateFrameNumber, ...
                                             slider_frames});
                    
                        
    end
    function update_mouseGUI(ax, vm, frame)
        % updates mouse image
        if isFirstMouse
            tmpFrame = vm(:,:,1,frame);
            if isFlipped
                tmpFrame = fliplr(vm(:,:,1,frame));
            end
            im = imagesc(ax, tmpFrame);
            colormap gray;
            isFirstMouse = 0;
            updateRectangles();
        else
            tmpFrame = vm(:,:,1,frame);
            if isFlipped
                tmpFrame = fliplr(vm(:,:,1,frame));
            end
            set(im, 'CData', tmpFrame);
        end
    end
    function updateBBvals(view)
        switch view
            case 'side'
                set(tbl_sv, 'string', num2str(bb.sv_vals));
            case 'bottom'
                set(tbl_bv, 'string', num2str(bb.bv_vals));
        end
    end
    function save_to_yml(src, evt)
        % read yml file
        
        % get yml file
        ymlfile = lm_uigetfile('*.yml', 'Select YML file.');
        
        if ymlfile~=0
            content = lm_readYML(ymlfile);
            
            % find lines for BB definition
            bb.sv_line = find_BBline(content, 'side');
            bb.bv_line = find_BBline(content, 'bottom');
            
            % write new data assuming they are placed Nlines after BB header
            content = writeNewBBlines(content, Nlines, bb);
            
            % overwrite YML file
            lm_writeYML(ymlfile, content);
        end
    end
    function updateRectangles(view)
        % side is green, bottom is yellow
        if isFirstRect % first time created
            hold on;
            bb.r_sv = rectangle();
            bb.r_bv = rectangle();
            set(bb.r_sv, 'Visible', 'Off');
            set(bb.r_bv, 'Visible', 'Off');
            isFirstRect = 0;
        else
            switch view
                case 'side'
                    set(bb.r_sv, 'Visible', 'On');
                    set(bb.r_sv, 'position', bb.sv_vals);
                    set(bb.r_sv, 'edgecolor', 'g');
                case 'bottom'
                    set(bb.r_bv, 'Visible', 'On');
                    set(bb.r_bv, 'position', bb.bv_vals);
                    set(bb.r_bv, 'edgecolor', 'y');
            end
        end
    end
    function flipFrame(src, evt)
        if ~isFlipped
            isFlipped = 1;
        else
            isFlipped = 0;
        end
        update_mouseGUI(ax, vm, frame);
    end
    function updateFrameNumber(src, evt, inval)
        
        frame = floor(inval.Value*vdata.nFrames);
        if frame < 1
            frame = 1;
        elseif frame > vdata.nFrames
            frame = vdata.nFrames;
        end
        update_mouseGUI(ax, vm, frame);
    end
end

function line_num = find_BBline(content, view)
switch view
    case 'side'
        tgt_str = 'bounding_box_side: ';
    case 'bottom'
        tgt_str = 'bounding_box_bottom: ';
end

for I=1:length(content)
    if strfind(content{I}, tgt_str)
        line_num = I;
        break;
    end
end

end
function content = writeNewBBlines(content, Nlines, bb)
%        data: [59, 129, 300, 120]…

tgt_line_sv_bb = bb.sv_line + Nlines;
tgt_line_bv_bb = bb.bv_line + Nlines;

content{tgt_line_sv_bb} = ...
    sprintf('   data: [%g, %g, %g, %g]...\n', bb.sv_vals(1), ...
                                              bb.sv_vals(2),...
                                           bb.sv_vals(3), bb.sv_vals(4));
content{tgt_line_bv_bb} = ...
    sprintf('   data: [%g, %g, %g, %g]...\n', bb.bv_vals(1), ...
                                              bb.bv_vals(2),...
                                           bb.bv_vals(3), bb.bv_vals(4));
end