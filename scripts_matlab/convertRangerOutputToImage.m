function convertRangerOutputToImage(dataPath, ORIGINAL_DATA_PATH)

addpath('NIfTI_20140122')

% const_threshold = 0.5;

ORIGINAL_DATA_PATH = ORIGINAL_DATA_PATH;
outputFromRanger = [dataPath, '/PredictedImages/'];
EXPORT_PATH = [dataPath, '/predictedLesion'];
% ORIGINAL_DATA_PATH = '/Users/DGS/ownCloud/Obelix/Daten/ISLES-challenge/SISS2015_Training/SISS2015/Training/';
% ORIGINAL_DATA_PATH='/data/data_l50b/ImageData/ISLES-challenge/SISS2015_Training/SISS2015/Training';
% dataPath='../../Output';
% EXPORT_PATH = 'resultsFolder/predictedLesion/';
mkdir(EXPORT_PATH);
% Find all the folders!
foldersInTrainingData = dir(outputFromRanger);

const_numberOfPatients = 0;

% FIND NUMBER OF PATIENTS
for iNumberOfFiles = 1:size(foldersInTrainingData,1)
  if (strfind(foldersInTrainingData(iNumberOfFiles).name, 'Patient')==1)
    const_numberOfPatients = const_numberOfPatients + 1;
  end
end



for iNumberOfPatients = 1:const_numberOfPatients

  disp(['Patient_', num2str(iNumberOfPatients)])

  % IMPORT RANGER DATA
  rangerData = importdata([outputFromRanger,'Patient_', num2str(iNumberOfPatients), '/ranger_out.prediction']);

  if iNumberOfPatients < 10
    searchStr = ['0', num2str(iNumberOfPatients)];
  else
    searchStr = num2str(iNumberOfPatients);
  end

  foldersInTestData = dir(ORIGINAL_DATA_PATH);

  for iNumberOfTestFolders = 1:size(foldersInTestData,1)

  if (strcmp(foldersInTestData(iNumberOfTestFolders).name, searchStr)==1)

    filesInFolder = getAllFiles([ORIGINAL_DATA_PATH, '/', num2str(searchStr)]);

    desiredFiles = [];

    for iNumberOfFiles = 1:size(filesInFolder,1)
      if ~isempty(strfind(filesInFolder{iNumberOfFiles}, 'nii'))
        desiredFiles{end + 1} = filesInFolder{iNumberOfFiles};
      end
    end


    for iNumberOfFiles = 1:size(desiredFiles,2)

      if strfind(desiredFiles{iNumberOfFiles}, 'O.OT')
        %     % IMPORT
        MaskImage = load_nii(desiredFiles{iNumberOfFiles});
        figure(1)
        subplot(1,2,1)
        imshow(MaximumIntensityProjection(MaskImage.img),[])

      end

    end


  end

  end


% CONVERT VECTOR TO MATRIX
thresholdedData = rangerData.data(2:end,1);

% Threshold data
% thresholdedData(thresholdedData < const_threshold) = 0;%
% thresholdedData(thresholdedData >= const_threshold) = 1;%

reshapedData = reshape(thresholdedData,[230 230 154]);
%reshapedData = im2uint16(reshapedData);

figure(1)
subplot(1,2,2)
imshow(MaximumIntensityProjection(reshapedData),[]);
drawnow
if iNumberOfPatients < 10
    fileName = [EXPORT_PATH , '/patient_0' , num2str(iNumberOfPatients), '.nii'];
else
    fileName = [EXPORT_PATH , '/patient_' , num2str(iNumberOfPatients), '.nii'];
end

datatype = 512;
% generatedNifti = make_nii(reshapedData, [], [], datatype);
generatedNifti = make_nii(reshapedData);
% generatedNifti.hdr=MaskImage.hdr;

save_nii(generatedNifti, fileName);

dice = calculateDiceCoefficient(reshapedData, MaskImage.img);
disp(['   DICE: ', num2str(dice)]);

end


% fileName = ['resultsFolder/predictedLesion_', 'treshold_' , num2str(const_threshold), '.nii']
%
% generatedNifti = make_nii(reshapedData);
%
% save_nii(generatedNifti, fileName);
% figure, imshow(MaximumIntensityProjection(reshapedData));




% pd = fitdist(nonzeros(thresholdedData), 'Gamma')
%
% x_values = 0:0.01:1.5;
% y = pdf(pd,x_values);
% plot(x_values,y,'LineWidth',2)
%
% cd = cdf(pd, reshapedData);
% ni = norminv(cd, reshapedData);
%
% -norminv(cdf(pd, 0.6))

end
