function out = lm_YMLvar_isa(yaml_file, vartype)
% tests what a variable in a YML file is, just like matlab's 'isa' function
% requires the yaml file to contain only one variable

content = lm_readYML(yaml_file);

nLines = length(content);
lines = 0;
for lines=1:nLines
     if ~isempty(strfind(content{lines}, ':')) && ...
         isempty(strfind(content{lines}, '!!opencv-matrix')) && ...
         isletter(content{lines}(1)) && ...
         isempty(strfind(content{lines}, 'N_opencv_matrices'))
         I=lines;
     end
end

if lines==0
    disp('failed to find the  variable');
    return;
end

colonpos = strfind(content{I},':');

switch vartype
    case 'scalar'
        % this is a number right after the colon
        result = str2num(content{I}(colonpos+1:end));
        out = ~isempty(result);
    case 'matrix'
        % matrix, matlab-style
        result = strfind(content{I}(colonpos+1:end), '[');
        out = ~isempty(result);
    case 'struct'
        % simple struct. there should be nothing following the colon and
        % the next line should start with some kind of tab or spaces for
        % indentation. after that, there should be another colon
        a = regexprep(content{I}(colonpos+1:end), '\W', '');
        a = isempty(a);
        % check the next line only if a is true
        if a
            b = ~isletter(content{I+1}(1))&&~isletter(content{I+1}(2))&&...
                ~isletter(content{I+1}(3));
            c = ~strcmp(content{I+1}(4), '-');
            out = a && b && c;
        else
            out = 0;
        end
    case 'structarray'
        % the big mean animal starting with dashes right after the variable
        % name
        % simple struct. there should be nothing following the colon and
        % the next line should start with some kind of tab or spaces for
        % indentation. after that, there should be another colon
        a = regexprep(content{I}(colonpos+1:end), '\W', '');
        a = isempty(a);
        % check the next line
        if a
            b = ~isletter(content{I+1}(1))&&~isletter(content{I+1}(2))&&...
                ~isletter(content{I+1}(3));
            % now c needs  to find a dash
            c = strcmp(content{I+1}(4), '-');
            out = a && b && c;
        else
            out = 0;
        end
    otherwise
        disp(sprintf('Unkknown vartype (%s)', mfilename));
end

end