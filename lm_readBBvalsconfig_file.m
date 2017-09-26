function bb = lm_readBBvalsconfig_file(config_file)
% reads bounding box parameters from configuration file
content = lm_readYML(config_file);

bblineside = [];
bblinebot  = [];

for ii = 1:numel(content)
    if strfind(content{ii}, 'bounding_box_side')
        bblineside = ii+4;
    elseif strfind(content{ii}, 'bounding_box_bottom')
        bblinebot = ii+4;
    end
end

% find limits []
bblineside_lims(1) = strfind(content{bblineside}, '[');
bblineside_lims(2) = strfind(content{bblineside}, ']');

bblinebot_lims(1) = strfind(content{bblinebot}, '[');
bblinebot_lims(2) = strfind(content{bblinebot}, ']');

bb.side = str2num(content{...
                bblineside}(bblineside_lims(1):bblineside_lims(2)));
bb.bottom = str2num(content{...
                bblinebot}(bblinebot_lims(1):bblinebot_lims(2)));

end