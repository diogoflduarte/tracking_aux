function content = lm_readYML(ymlfile)
% reads YML file
% Diogo Duarte (2017)

if ymlfile~=0
    
    fid = fopen(ymlfile, 'r');
    
    content = cell(50,1); % just a number
    
    tline = fgets(fid);
    line_counter = 1;
    
    content{line_counter} = tline;
    while ischar(tline)
        %     disp(tline);
        
        tline = fgets(fid);
        line_counter = line_counter + 1;
        content{line_counter} = tline;
    end
    
    fclose(fid);
    
content=content(~cellfun('isempty',content));
    
end
end