function convertImageDataToPredictorMatrix(OUTPUT_PATH)

addpath('NIfTI_20140122/');
% IMPORT files

% Select data
% SET FEATURE DATA PATH
% trainingDataFolder = '../../Training_features';
% exportFolder = 'resultsFolder/vectorizedImages';
trainingDataFolder = [OUTPUT_PATH,'/generatedFeatures'];
exportFolder = [OUTPUT_PATH, '/vectorizedImages'];
mkdir(exportFolder)

% Find all the folders!
foldersInTrainingData = dir(trainingDataFolder);

const_numberOfPatients = 0;

for iNumberOfFiles = 1:size(foldersInTrainingData,1)
  if (strfind(foldersInTrainingData(iNumberOfFiles).name, 'Patient')==1)
    const_numberOfPatients = const_numberOfPatients + 1;
  end
end


iIterator = 1;
for iNumberOfPatients = 1:const_numberOfPatients

  searchStr = ['Patient_', num2str(iNumberOfPatients)];

for iNumberOfFiles = 1:size(foldersInTrainingData,1)
  if strcmp(foldersInTrainingData(iNumberOfFiles).name, searchStr) == 1

    patientFolder{iIterator} = foldersInTrainingData(iNumberOfFiles);
    patientFolder{iIterator}.name

    iIterator = iIterator + 1;

  end

end


%% Select image files
fileList = getAllFiles(strcat(trainingDataFolder,'/' , patientFolder{iNumberOfPatients}.name));
desiredFiles = [];

for iNumberOfFiles = 1:size(fileList,1)
  if ~isempty(strfind(fileList{iNumberOfFiles}, 'nii'))
    desiredFiles{end + 1} = fileList{iNumberOfFiles};
  end
end


for iNumberOfFiles = 1:size(desiredFiles,2) - 1
  featureImages(iNumberOfFiles) = load_nii(desiredFiles{iNumberOfFiles});
end


% VECTORIZE FEATURE IMAGE
for iNumberOfFeatures = 1:size(featureImages,2)
  featureVector(:, iNumberOfFeatures) = featureImages(iNumberOfFeatures).img(:);
end

% SAVE VECTORIZED FEATURE IMAGE
% for iNumberOfFeatures = 1:size(featureVector,2)+1
%
%   if iNumberOfFeatures == 1
%     finalTable(:,1) = table(zeros(size(featureVector,1),1));
%   else
%     finalTable(:,iNumberOfFeatures) = table(featureVector(:,iNumberOfFeatures-1));
%   end
%
% end


% -----------------------------------------------------------------
% Export all the data
% -----------------------------------------------------------------

% Generate column names
for iNumberOfFeatures =  1:size(featureVector,2)
  columnNames{iNumberOfFeatures} = ['feature_', num2str(iNumberOfFeatures)];
end

% columnNames{1} = 'lesion';

fileName =['vectorizedFeatureImageDataPatientNo_', num2str(iNumberOfPatients)]

featureTable = array2table(featureVector, 'VariableNames',columnNames);
writetable(featureTable, ...
  [exportFolder, '/vectorizedFeatureImageDataPatientNo_', num2str(iNumberOfPatients) ])

end

% clearvars -except structTrainingData appendedTrainingData columnNames

% lesion = zeros(size(featureVector,1),1);
% feature1  = featureVector(:,1);
% feature2  = featureVector(:,2);
% feature3  = featureVector(:,3);
% feature4  = featureVector(:,4);
% feature5  = featureVector(:,5);
% feature6  = featureVector(:,6);
% feature7  = featureVector(:,7);
% feature8  = featureVector(:,8);
% feature9  = featureVector(:,9);
% feature10 = featureVector(:,10);
% feature11 = featureVector(:,11);
% feature12 = featureVector(:,12);
% feature13 = featureVector(:,13);
% feature14 = featureVector(:,14);
% feature15 = featureVector(:,15);
% feature16 = featureVector(:,16);
%
% finalTable = table(lesion, feature1, feature2, feature3, feature4, ...
%   feature5, feature6, feature7, feature8, feature9, feature10, feature11, ...
%   feature12, feature13, feature14, feature15, feature16);

% writetable(finalTable, 'vectorizedFeatureImageDataPatientNo28.dat')

end
