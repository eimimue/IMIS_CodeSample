% Script to extract the features from the imaging data and convert the data in a
% format which is readable for ranger

function generateFeatures(pathToTrainingData)
addpath('NIfTI_20140122/');

% -----------------------------------------------------------------
% DEFINE INPUT / OUTPUT PATHS
% -----------------------------------------------------------------
% Select data
% SET FEATURE DATA PATH
% trainingDataFolder = '../../Training_features';
% SET EXPORT PATH
% exportPATH = '../../sampleFeatures';
trainingDataFolder = [pathToTrainingData, '/generatedFeatures']
exportPATH = [pathToTrainingData, '/sampledFeatures'];
mkdir(exportPATH)

% prompt = ['Export folder is defined as ', exportPATH, ' Do you want to continue (y/n)? '];
% x = input(prompt,'s');
%
% if strcmp(x,'y')
%   disp('Creating directory...');
%   mkdir(exportPATH)
% elseif strcmp(x,'n')
%   disp('Terminating script.');
%   return
% else
%   disp('Please answer yes or no.');
%   return
% end

% -----------------------------------------------------------------
%% IMPORT
% -----------------------------------------------------------------

iNumberOfNames = 1;

% Find all the folders!
foldersInTrainingData = dir(trainingDataFolder);

iIterator = 1;
for iNumberOfFiles = 1:size(foldersInTrainingData,1)
  if strfind(foldersInTrainingData(iNumberOfFiles).name, 'Patient') == 1

    patientFolder(iIterator) = foldersInTrainingData(iNumberOfFiles);

    iIterator = iIterator + 1;

  end

end

% Set some constant values for better readability
const_numberOfPatientFolders = size(patientFolder,2);


% Initialize arrays for the assembly of generated feature vectors
sortedAppendArrayLesion = [];
sortedAppendArrayBrain = [];

% -----------------------------------------------------------------
%% Iterate through every patient folder
% -----------------------------------------------------------------
for iNumberOfPatients = 1:const_numberOfPatientFolders
disp(['Generating data for Folder No. ', num2str(iNumberOfPatients)])

  %% Select mask files
  fileList = getAllFiles(strcat(trainingDataFolder,'/' , patientFolder(iNumberOfPatients).name));
  desiredFiles = [];

  for iNumberOfFiles = 1:size(fileList,1)
    if ~isempty(strfind(fileList{iNumberOfFiles}, 'nii'))
      desiredFiles{end + 1} = fileList{iNumberOfFiles};
    end
  end

  for iNumberOfFiles = 1:size(desiredFiles,2)

    if strfind(desiredFiles{iNumberOfFiles}, 'O.OT')
      lesionMask = load_nii( desiredFiles{iNumberOfFiles});
    end
  end
  %% END: Select mask files

  const_numberOfModalities = 4;
  const_sizeOfPatientPerFolder = size(desiredFiles,2)-1;
  const_numberOfFeatures = const_sizeOfPatientPerFolder / const_numberOfModalities;

  % -----------------------------------------------------------------
  %% Import feature images
  % -----------------------------------------------------------------
  for iNumberOfAllFeatures = 1:const_numberOfModalities * const_numberOfFeatures

    featureImages(iNumberOfAllFeatures) = load_nii( ...
      desiredFiles{iNumberOfAllFeatures});

  end

    % -----------------------------------------------------------------
    %% Generate random voxel indices
    % -----------------------------------------------------------------
    numberOfSpotsMask = 300;
    if length(nonzeros(lesionMask.img)) < numberOfSpotsMask
      numberOfSpotsMask = length(nonzeros(lesionMask.img));
    end

    % Number of spots should be twice as high as in the lesion mask
    numberOfSpotsBrain = numberOfSpotsMask * 2;

    theInversion = (double(lesionMask.img) - 1) .* -1;
    brainWithoutLesion = featureImages(1).img .* theInversion;

    brainWithoutLesion(brainWithoutLesion==mode(mode(mode(brainWithoutLesion)))) = 0;
    brainWithoutLesion(brainWithoutLesion~=0) = 1;

    % Generate random voxels with approximately 300 voxels located in the lesion mask
    numberOfValidLesionRandomNumbers = 0;
    numberOfValidBrainRandomNumbers = 0;
    iNumberOfRandomNumbers = 5e7; % initial value for number of random numbers

    if numberOfSpotsMask == 300
      theCriterion = (numberOfValidLesionRandomNumbers < numberOfSpotsMask ||  numberOfValidBrainRandomNumbers < 2*numberOfSpotsMask);
    else
      theCriterion = numberOfValidBrainRandomNumbers < 2*numberOfSpotsMask;
    end

    % Iterate until enough random voxels are located within the lesion mask
    while theCriterion == true

      iNumberOfRandomNumbers = iNumberOfRandomNumbers + 500;

      randomNumbers(:,1) = randi(size(lesionMask.img,1), iNumberOfRandomNumbers, 1);
      randomNumbers(:,2) = randi(size(lesionMask.img,2), iNumberOfRandomNumbers, 1);
      randomNumbers(:,3) = randi(size(lesionMask.img,3), iNumberOfRandomNumbers, 1);

      randomNumberMatrix = zeros(size(lesionMask.img,1), size(lesionMask.img,2), ...
        size(lesionMask.img,3));

      % Build a image matrix from random generated numbers
      for irandomNumber = 1:iNumberOfRandomNumbers
        randomNumberMatrix(randomNumbers(irandomNumber,2), randomNumbers(irandomNumber,1), ...
          randomNumbers(irandomNumber,3)) = 1;
      end


      validLesionRandomNumbers = randomNumberMatrix .* double(lesionMask.img);
      numberOfValidLesionRandomNumbers = size(nonzeros(validLesionRandomNumbers),1);

      validBrainRandomNumbers = randomNumberMatrix .* brainWithoutLesion;
      numberOfValidBrainRandomNumbers = size(nonzeros(validBrainRandomNumbers),1);

      clear randomNumbers;
      clear randomNumberMatrix;

      if numberOfSpotsMask == 300
        theCriterion = (numberOfValidLesionRandomNumbers < numberOfSpotsMask ||  numberOfValidBrainRandomNumbers < 2*numberOfSpotsMask);
      else
        theCriterion = numberOfValidBrainRandomNumbers < 2*numberOfSpotsMask;
      end

    end

    % If lesion is smaller than 300: select every voxel of lesion mask
    if numberOfSpotsMask < 300
      validLesionRandomNumbers = double(lesionMask.img);
    end


    % -----------------------------------------------------------------
    % Extract values in random voxels
    % -----------------------------------------------------------------

    for iNumberOfFeatures = 1 : const_numberOfModalities * const_numberOfFeatures
      disp(['--> Generating Feature No. ', num2str(iNumberOfFeatures)])

      maskedBrainFeatures(:,:,:,iNumberOfFeatures)  = validBrainRandomNumbers  .* double(featureImages(iNumberOfFeatures).img);
      maskedLesionFeatures(:,:,:,iNumberOfFeatures) = validLesionRandomNumbers .* double(featureImages(iNumberOfFeatures).img);

    end


  % -----------------------------------------------------------------
  %% Sort results / array
  % -----------------------------------------------------------------

sizeOfLesionMatrix = 1e100;
sizeOfBrainMatrix = 1e100;
  for iNumberOfFeatures = 1 : const_numberOfFeatures * const_numberOfModalities

    tmpSizeOfLesionMatrix = size(nonzeros(maskedLesionFeatures(:,:,:,iNumberOfFeatures)), 1);
    tmpSizeOfBrainMatrix  = size(nonzeros(maskedBrainFeatures(:,:,:,iNumberOfFeatures)), 1);

    if tmpSizeOfLesionMatrix < sizeOfLesionMatrix
      sizeOfLesionMatrix = tmpSizeOfLesionMatrix;
      indexOfSizeLesionMatrix = iNumberOfFeatures;
    end

    if tmpSizeOfBrainMatrix < sizeOfBrainMatrix
      sizeOfBrainMatrix = tmpSizeOfBrainMatrix;
      indexOfSizeBrainMatrix = iNumberOfFeatures;
    end

  end


  randomNumbersMask  =  datasample(find(lesionMask.img == 1)    , numberOfSpotsMask);
  randomNumbersBrain =  datasample(find(brainWithoutLesion == 1), numberOfSpotsBrain);


  for iNumberOfFeatures = 1:const_numberOfModalities * const_numberOfFeatures

    tmpVar = maskedLesionFeatures(:,:,:,iNumberOfFeatures);
    sortedArrayLesion(:,iNumberOfFeatures + 1 ) = tmpVar(randomNumbersMask);

    sortedArrayLesion(:,1) = ones(size(sortedArrayLesion,1),1);

    tmpVar = maskedBrainFeatures(:,:,:,iNumberOfFeatures);
    sortedArrayBrain(:,iNumberOfFeatures + 1 ) = tmpVar(randomNumbersBrain);

    sortedArrayBrain(:,1) = zeros(size(sortedArrayBrain,1),1);

    structTrainingData{iNumberOfPatients}    = vertcat(sortedArrayLesion, sortedArrayBrain);
  end

  clearvars -except trainingDataFolder patientFolder structTrainingData exportPATH

  end % end loop of feature generation for patients

  % -----------------------------------------------------------------
  % Export all the data
  % -----------------------------------------------------------------
  disp('Saving structTrainingData...');
  save([exportPATH, '/structTrainingData.mat'], 'structTrainingData')

end
