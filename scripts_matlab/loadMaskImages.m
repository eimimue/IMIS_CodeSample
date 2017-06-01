function MaskImage= loadMaskImages(ORIGINAL_DATA_PATH)

% Find all the files
filesPredictedPatients = dir(ORIGINAL_DATA_PATH);

% FIND NUMBER OF PATIENTS
const_numberOfPatients = str2num(filesPredictedPatients(end).name);


for iNumberOfPatients = 1:const_numberOfPatients

  disp(['Importing mask of Patient_', num2str(iNumberOfPatients)])

  if iNumberOfPatients < 10
    searchStr = ['0', num2str(iNumberOfPatients)];
  else
    searchStr = num2str(iNumberOfPatients);
  end

  filesInFolder = getAllFiles([ORIGINAL_DATA_PATH, '/', num2str(searchStr)]);
  desiredFiles = [];

    for iNumberOfFiles = 1:size(filesInFolder,1)
      if ~isempty(strfind(filesInFolder{iNumberOfFiles}, 'nii'))
        desiredFiles{end + 1} = filesInFolder{iNumberOfFiles};
      end
    end

    % -------------------------
    % IMPORT MASK IMAGE DATA
    % -------------------------
    for iNumberOfFiles = 1:size(desiredFiles,2)

      if strfind(desiredFiles{iNumberOfFiles}, 'O.OT')

        MaskImage{iNumberOfPatients} = load_nii(desiredFiles{iNumberOfFiles});

      end

    end


  end

  end
