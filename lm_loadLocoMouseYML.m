function D = lm_loadLocoMouseYML(yaml_file)
fid = fopen(yaml_file,'r');

if fid < 0
    error('Failed to read input file %s.',yaml_file);
end

% Prevents problems when code crashes.
% safe_fid = onCleanup(@()(fclose(fid)));

line = fgetl(fid);
hdrline = '%YAML:1.0';

if ~strcmpi(line,hdrline)
    error('This function reads only YAML:1.0 files. Such files should have the appropriate "%YAML:1.0" header.');
end

line = fgetl(fid);
fields = strsplit(line,':');
if strcmpi(fields{1},'N_opencv_matrices')
    N_opencv_matrices = str2double(fields{2});
    M = readOpenCVMat(fid,N_opencv_matrices);
    
    % Assigning M to the correct fields of D:
    D.M = cat(1,M{1:2}) + 1;
    D.M_top = cat(1,M{3:7}) + 1;
    
    rest_of_file = fscanf(fid,'%c',inf);
else
    rest_of_file = fscanf(fid,'%c',inf);
    rest_of_file = cat(1,sprintf('%s\n',line),rest_of_file);
end

% file is no longer needed
fclose(fid);

% .............. DD .......................................................
% find where each field starts and ends
% will read the file again, my way, for finding lines
content = lm_readYML(yaml_file);

% find non opencv matrix lines (other data)
lines = findNonOpenCV(content);

% build bounds
yml_bounds = zeros(numel(lines), 2);
for I=1:numel(lines)-1
    yml_bounds(I, 1) = lines(I);
    yml_bounds(I, 2) = lines(I+1)-1;
end
yml_bounds(end,1) = lines(end);
yml_bounds(end,2) = length(content); % until the end

% split them into different files
fnms = make_YML_tmp_files(yaml_file, content, yml_bounds, hdrline);

% read them in a for loop
for f = 1:numel(fnms)
    S_{f} = YAML.read(fnms{f});
end
% merge them
S = mergeS_cell(S_);

% Transform the YAML structure into the expected MATLAB structure:
% Note: C++ coordinates start at 0.
D.occluded_distance = S.occluded_distance;
D.bounding_box = [S.bb_x_avg(:) S.bb_yb_avg(:) S.bb_yt_avg(:)]' + 1;
D.bounding_box_dim = [S.BB_bottom.width;S.BB_bottom.height;S.BB_top.height];
D.Occlusion_Grid_Bottom = bsxfun(@minus,D.bounding_box_dim(1:2),reshape(S.ONG.x_y_coordinates,2,S.ONG.points));
D.xvel = diff(S.bb_x_avg(:))';
D.Occlusion_Vect_Top = S.ONG_top.z_coordinates(:)' + 1;
D.nong_vect = D.Occlusion_Vect_Top + 1;
D.Unary = cell(2,S.N_frames);
D.Pairwise = cell(2,S.N_frames);
D.tracks_bottom = cell(2,S.N_frames);
D.tracks_top = cell(5,S.N_frames);
% D.occluded_distance = S.occluded_distance;

Nong_bottom = size(D.Occlusion_Grid_Bottom,2);

x_offset = D.bounding_box(1,:) - S.BB_bottom.width + 1;
yb_offset = D.bounding_box(2,:) - S.BB_bottom.height + 1;
yt_offset = D.bounding_box(3,:) - S.BB_top.height + 1;

for i_frames = 1:S.N_frames
    % Paws:
    [D.tracks_bottom{1,i_frames},D.tracks_top(1:4,i_frames)] = getTracks(S.candidates_paw_bottom_top_matched{i_frames},D.M(1:4,i_frames),x_offset(i_frames),yb_offset(i_frames), yt_offset(i_frames));
      
    %Snout:
    [D.tracks_bottom{2,i_frames}, D.tracks_tail(5,i_frames)] = getTracks(S.candidates_paw_bottom_top_matched{i_frames},D.M(5,i_frames), x_offset(i_frames), yb_offset(i_frames), yt_offset(i_frames));
   
    % Unary:
    D.Unary{1,i_frames} = getMatrix(S.Unary_paws(i_frames));
    D.Unary{2,i_frames} = getMatrix(S.Unary_snout(i_frames));
    
    % Pairwise:
    if i_frames < S.N_frames
        D.Pairwise{1,i_frames} = getPairwise(S.Pairwise_paws(i_frames));
    end
    
    if i_frames < S.N_frames
        D.Pairwise{2,i_frames} = getPairwise(S.Pairwise_snout(i_frames));
    end
        
end
clear tracks_bottom;
for f = 1:length(fnms)
    delete(fnms{f});
end

function M = readOpenCVMat(fid, N)

M = cell(1,N);

for i_mat = 1:N
    
    % Matrix name:
    line = fgetl(fid);
    fields = strsplit(line,': ');
    
    load_error = false;
    if length(fields) < 2
        load_error = true;
    elseif ~strcmpi(fields{2},'!!opencv-matrix')
        load_error = true;
    end
    
    if load_error
        error('Failed to read opencv-matrix. Check if the number of matrices is properly defined.');
    end
    
    row_line = strsplit(fgetl(fid),': ');
    N_rows = str2double(row_line{2});
    
    col_line = strsplit(fgetl(fid),': ');
    N_cols = str2double(col_line{2});
    
    data_line = strsplit(fgetl(fid),': ');
    data_type = data_line{2};
    
    %Data lines:
    M{i_mat} = zeros(N_cols,N_rows); % C++ is row major!
    
    if strcmpi(data_type, 'u')
        M{i_mat} = uint8(M{i_mat});
    end
    
    line = fgetl(fid);
    fields = strsplit(line,': ');
    first_line_num = sscanf(fields{2}(2:end),'%f,',inf);
    N_first_line = length(first_line_num);
    
    M{i_mat}(1:N_first_line) = first_line_num;
    
    if N_first_line < numel(M{i_mat})
        M{i_mat}((N_first_line+1):end) = fscanf(fid,'%f,',inf);
        fgetl(fid); %rest of last line
    end
    
    M{i_mat} = M{i_mat}';
end
end
function [tracks_bottom,tracks_top] = getTracks(struct,M, x_bias, y_bias, z_bias)
N_candidates = length(struct);
tracks_bottom = zeros(3,N_candidates);

tracks_top = cell(size(M,1),1);

for i_tb = 1:N_candidates
    tracks_bottom(1,i_tb) = struct(i_tb).Candidate_bottom.Point_x + x_bias;
    tracks_bottom(2,i_tb) = struct(i_tb).Candidate_bottom.Point_y + y_bias;
    tracks_bottom(3,i_tb) = struct(i_tb).Candidate_bottom.Score;
end

for i_tt = 1:size(M,1)
    
    if M(i_tt) <= N_candidates
        tracks_top{i_tt} = zeros(4,struct(M(i_tt)).n_candidates_top);
        tracks_top{i_tt}(1:2,:) = repmat(tracks_bottom(1:2,M(i_tt)),1,struct(M(i_tt)).n_candidates_top);
        tracks_top{i_tt}(3,:) = struct(M(i_tt)).Candidates_top + z_bias;
        tracks_top{i_tt}(4,:) = struct(M(i_tt)).Scores_top;
    else
        tracks_top{i_tt} = zeros(4,0);
    end
end
end
function P = getPairwise(pairwise_mat_struct)
% C++ index starts at 0
P = sparse(pairwise_mat_struct.row_index+1,pairwise_mat_struct.col_index+1,pairwise_mat_struct.data);
end
function M = getMatrix(mymat_struct)
% C++ index starts at 0!
M = reshape(mymat_struct.data,mymat_struct.n_rows,mymat_struct.n_cols);
end


end

function lines = findNonOpenCV(content)
nLines = length(content);
lines = [];
for I=1:nLines
     if ~isempty(strfind(content{I}, ':')) && ...
         isempty(strfind(content{I}, '!!opencv-matrix')) && ...
         isletter(content{I}(1)) && ...
         isempty(strfind(content{I}, 'N_opencv_matrices'))
         lines = [lines I];
     end
end
end

function fnms = make_YML_tmp_files(yaml_file, content, yml_bounds, hdrline)
% this function takes the content of the yaml_file, crops it according with
% the bounds, adds the header line to the top and then saves then as
% individual yml files

[~,yaml_file,~] = fileparts(yaml_file);

% replace % with %% so that matlab does not generate an error
for j=1:length(content)
   content{j} = strrep(content{j}, '%', '%%'); 
end

numFiles = size(yml_bounds,1);
fnms = cell(numFiles,1); % storing filenames

for I=1:numFiles
    % generate file name
    tmpFN = sprintf('_%s_FN%g.yml',yaml_file, I);
    fnms{I} = tmpFN;
    % fopen it
    fid_ = fopen(tmpFN, 'w+');
    
    % print lines into new file
    % print header
%     fprintf(fid_, '%s\n', hdrline);
    % calculate  numLines
    numLines = yml_bounds(I,2)-yml_bounds(I,1)+1;
    for k=1:numLines
        fprintf(fid_, '%s', content{yml_bounds(I,1)+k-1});
    end
    
    % fclose file
    fclose(fid_);
end
end
function S = mergeS_cell(S_)
% get cell length
numCells = length(S_);
% generate struct S
S = struct();
% stack it iteratively
for I=1:numCells
    fields_sep = fieldnames(S_{I});
    for J=1:length(fields_sep)
        S.(sprintf('%s',fields_sep{J})) = ...
            S_{I}.(sprintf('%s',fields_sep{J}));
    end
end
end