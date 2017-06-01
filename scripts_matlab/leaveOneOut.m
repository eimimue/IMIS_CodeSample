function leaveOneOut(dataGeneratedFeatures, exportFolder)

% -----------------------------------------------------------------
% Import all the data
% -----------------------------------------------------------------
exportFolder = [exportFolder, '/featureTables'];
mkdir(exportFolder)


structTrainingData = load(dataGeneratedFeatures);
% structTrainingData = load('sampleFeatures/structTrainingData.mat');

% -----------------------------------------------------------------
% LEAVE ONE OUT!
% -----------------------------------------------------------------


% Generate column names
for iNumberOfFeatures =  2:size(structTrainingData.structTrainingData{1},2)
  columnNames{iNumberOfFeatures} = ['feature_', num2str(iNumberOfFeatures - 1)];
end

columnNames{1} = 'lesion'

% Iterate through every patient
for iNumberOfPatients = 1:size(structTrainingData.structTrainingData,2)
  appendedTrainingData = [];

  tmpstructTrainingData = structTrainingData.structTrainingData;
  tmpstructTrainingData(iNumberOfPatients) = [];

  for iNumberOfLeftPatients = 1:size(tmpstructTrainingData,2)

    appendedTrainingData = vertcat(appendedTrainingData, tmpstructTrainingData{:,iNumberOfLeftPatients});

  end


  % -----------------------------------------------------------------
  % Export all the data
  % -----------------------------------------------------------------
  fileName =['leftPatient_', num2str(iNumberOfPatients)   , '_Out.dat']

  featureTable = array2table(appendedTrainingData, 'VariableNames',columnNames);
  writetable(featureTable, [exportFolder, '/featureTableWithoutPatient_', num2str(iNumberOfPatients) ])

  clearvars -except structTrainingData appendedTrainingData columnNames exportFolder

end

end
