function lm_writeYML(ymlfile, content)
% writes YML file
% Diogo Duarte (2017)

% should go line by line in cell 'content'

% probably a good idea to backup original file
[p, ymlname, ext] = fileparts(ymlfile);
ymltwin = fullfile(p, strcat(ymlname, '_backup_drawBB', ext));
copyfile(ymlfile, ymltwin);

fid = fopen(ymlfile, 'w+');

% force wwriting first line (header), does not print due to '%Y'
% fprintf(fid, '%%YAML:1.0\n');

for I=1:length(content)-1
    content{I} = strrep(content{I},'%','%%');
    fprintf(fid, content{I});
end

fclose(fid);