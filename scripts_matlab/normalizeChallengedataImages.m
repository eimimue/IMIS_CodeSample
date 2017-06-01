% Script to normalize the ISLES challenge image data:
% The extent of the images is expanded to 154 in the z-direction.

clear all;
% -----------------------------------------------------------------
%% IMPORT
% -----------------------------------------------------------------
addpath('NIfTI_20140122/');

% YOU HAVE TO SET THIS DIRECTORY
challengedataDirectory = ...
 '/Users/DGS/ownCloud/Obelix/Daten/ISLES-challenge/SISS2015_Training/SISS2015/Training/';

% Select data
fileList = getAllFiles(challengedataDirectory);

% Extract file names for respective feature
desiredFiles = [];

for iNumberOfFiles = 1:size(fileList,1)

  if ~isempty(strfind(fileList{iNumberOfFiles}, 'nii'))
    desiredFiles{end + 1} = fileList{iNumberOfFiles};
  end

end

% Images are extended to 154 in the z-direction
for iNumberOfFiles = 1:size(desiredFiles,2)

  original3DData = load_nii(desiredFiles{iNumberOfFiles});

  if size(original3DData.img,3) == 153

    original3DData.img(:,:,154) = zeros(size(original3DData.img,1), size(original3DData.img,2));

    original3DData.original.hdr.dime.dim(4) = 154;
    original3DData.hdr.dime.dim(4) = 154;

    save_nii(original3DData, desiredFiles{iNumberOfFiles});

  end


end
