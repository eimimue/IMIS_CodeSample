function ranger_testdata

% IMPORT DATA

clear all

% IMPORT
dataPath = '/Users/DGS/Dropbox/Dissertation/RandomForestGump/code/Obelix/scripts_matlab/data.dat';
disp(dataPath)

importedData = importdata(dataPath);

testSize = round(size(importedData.data,1)/2);


randomNumbers = randperm(numel(importedData.data(:,1)), size(importedData.data,1));


% GENERATE TEST DATA
iIterator = 1;
for iNumberOfRandomNumbers = 1:round(size(randomNumbers,2)/2)

  testData(iIterator,:) = importedData.data(randomNumbers(iNumberOfRandomNumbers),:);
  iIterator = iIterator + 1;

end

% GENERATE TRAINING DATA
iIterator = 1;
for iNumberOfRandomNumbers = round(size(randomNumbers,2)/2)+1 : size(randomNumbers,2)

  trainingData(iIterator,:) = importedData.data(randomNumbers(iNumberOfRandomNumbers),:);
  iIterator = iIterator + 1;

end



partialTestData = testData;
partialTestData(:,1) = zeros(size(partialTestData,1),1);


% EXPORT TABLE
% SAVE VECTORIZED FEATURE IMAGE
for iNumberOfFeatures = 1:size(trainingData,2)
    finalTrainingTable(:,iNumberOfFeatures)        = table(trainingData(:,iNumberOfFeatures));
    finalTestTable(:,iNumberOfFeatures)            = table(testData(:,iNumberOfFeatures));
    finalPartialTestTable(:,iNumberOfFeatures)     = table(partialTestData(:,iNumberOfFeatures));
end

writetable(finalTrainingTable, 'flowerTrainingData.dat')
writetable(finalPartialTestTable, 'flowerTestData.dat')
writetable(finalTestTable, 'flowerTestDataComplete.dat')


importRangerPredictionOutput

end


% % -----------------------------------------------------------------------
% % -----------------------------------------------------------------------
% % -----------------------------------------------------------------------
function importRangerPredictionOutput

dataPath = '/Users/DGS/Ranger/ranger-master/source/build/ranger_out.prediction';
testDataPath = '/Users/DGS/Ranger/ranger-master/source/build/flowerTestDataComplete.dat';



testData = importdata(testDataPath);
predictorData = importdata(dataPath);

sumUp = 0;
for iNumberOfFeatures = 1:size(testData.data,1)
  if testData.data(iNumberOfFeatures,1) == predictorData.data(iNumberOfFeatures)
    sumUp = sumUp + 1;
  end
end

disp(['Prediction Precision : ', num2str(sumUp / size(testData.data,1) * 100), ' %'])

end
