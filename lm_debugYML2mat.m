function lm_debugYML2mat(yaml_file)
% converts YML debug file from locomouse t struct D (as usual) and then
% saves struct D in the same directory as the yaml file
%
% Diogo Duarte (2017)

[fullpath, filename, ~] = fileparts(yaml_file);

matfile = fullfile(fullpath, strcat(filename, '.mat'));

D = lm_loadLocoMouseYML(yaml_file);

save(matfile, '-struct', 'D');

end