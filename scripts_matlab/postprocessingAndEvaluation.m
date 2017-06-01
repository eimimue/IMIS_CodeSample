% postprocessingAndEvaluation
addpath('NIfTI_20140122')
% ++++++++++++++++++++++++++
% Define paramters
% ++++++++++++++++++++++++++

ORIGINAL_DATA_PATH = '/data/data_l50b/ImageData/ISLES-challenge/SISS2015_Training/SISS2015/Training';
dataPath = '../../Output';
PROBABILITY_MAP_DATA_PATH = [dataPath, '/predictedLesion'];
ORIGINAL_MASK_DATA_PATH   = ORIGINAL_DATA_PATH;

EVALUATION_BINARY = '../../../ISLESevaluation/build/ImageValidationISLES';

% Standard RF output thresholding params:
const_threshold = 0.5;
postProcessingIsThresholding = true;

% Contextual clustering params:
const_CCThreshold = 0.6;
const_CCIterations = 100;

% Definition of output fnames etc.:
if postProcessingIsThresholding == true
    fileNameAppenedix = 'thresholding';
    PREDICTED_MASK_DATA = [PROBABILITY_MAP_DATA_PATH, '/ThresholdedLesion'];
    EXPORT_PATH = [PROBABILITY_MAP_DATA_PATH, '/ThresholdedLesion'];
else
    fileNameAppenedix = 'clustering';
    PREDICTED_MASK_DATA = [PROBABILITY_MAP_DATA_PATH, '/ClusteredData'];
    EXPORT_PATH = [PROBABILITY_MAP_DATA_PATH, '/ClusteredData'];
end

mkdir(EXPORT_PATH);

% Find all the files
filesPredictedPatients = dir(PROBABILITY_MAP_DATA_PATH);

% FIND NUMBER OF PATIENTS
const_numberOfPatients = 0;
for iNumberOfFiles = 1:size(filesPredictedPatients,1)
    if (strfind(filesPredictedPatients(iNumberOfFiles).name, 'patient')==1)
        const_numberOfPatients = const_numberOfPatients + 1;
    end
end

% ++++++++++++++++++++++++++
% LOAD PROBABILITY MAP
% ++++++++++++++++++++++++++

for iNumberOfPatients = 1:const_numberOfPatients
    
    if iNumberOfPatients < 10
        probabilityData{iNumberOfPatients} = load_nii([PROBABILITY_MAP_DATA_PATH, '/patient_0', num2str(iNumberOfPatients), '.nii']);
        
    else
        probabilityData{iNumberOfPatients} = load_nii([PROBABILITY_MAP_DATA_PATH, '/patient_', num2str(iNumberOfPatients), '.nii']);
    end
    
end

% ++++++++++++++++++++++++++
% LOAD MASK
% ++++++++++++++++++++++++++
originalMaskImages = loadMaskImages(ORIGINAL_DATA_PATH);


% ++++++++++++++++++++++++++
% Apply postprocessing
% ++++++++++++++++++++++++++

% Apply threshold
% ---------------------------

% for iThreshold = const_threshold:0.05:1

clearvars thresholdedProbabilityData

thresholdedProbabilityData = probabilityData;

for iNumberOfPatients = 1:const_numberOfPatients
    
    thresholdedProbabilityData{iNumberOfPatients}.img(thresholdedProbabilityData{iNumberOfPatients}.img < ...
        iThreshold) = 0;
    thresholdedProbabilityData{iNumberOfPatients}.img(thresholdedProbabilityData{iNumberOfPatients}.img >= ...
        iThreshold) = 1;
    
end

% Apply contextutal clustering
% --------------------------
% Acc. to Halme et al., the applied contextual clustering approach follows
% Salli et al, "Contextual clustering for analysis of functional MRI data."
% IEEE Trans Med Imaging 20(5):403-14, 2001.

clusterData = probabilityData;

for iNumberOfPatients = 1:const_numberOfPatients
  
    % Step 1: Fitting gamma distribution to all nonzero pixels of RF 
    % probability map:
    gammaProbDist = fitdist( nonzeros( probabilityData{iNumberOfPatients}.img ),'Gamma' );

    % Step 2: Converting probability map distribution values to standard 
    % normal distribution:
    imageN = -norminv( cdf( gammaProbDist, probabilityData{iNumberOfPatients}.img ) );
    imageN( imageN == Inf ) = 0;
  
    % Step 3: Determining contextual clustering parameter: 
    T_CC = -norminv( cdf( gammaProbDist, const_CCThreshold ) );

    % Step 4: Actual contextual clustering:
    % (a) Initial segmentation
    currentCCSegm = imageN < T_CC;
    
    % (b) Clustering iteration
    for iCCIterations = 1:const_CCIterations
  
        filterMask = fspecial3( 'sum', 3 );
        u_i_Image = imfilter( double( currentCCSegm ), filterMask ) - double( currentCCSegm );
        modifiedProbMap = imageN + T_CC/6 * ( u_i_Image - 13 );
        currentCCSegm = modifiedProbMap < T_CC;
        
    end
    
    % Copy data to output data struct: 
    clusteredData{iNumberOfPatients}.img = currentCCSegm;
end

% ++++++++++++++++++++++++++
% Export data
% ++++++++++++++++++++++++++

datatype = 256; % uint8 datatype

for iNumberOfPatients = 1:const_numberOfPatients
    
    if iNumberOfPatients < 10
        fileName = [EXPORT_PATH , '/patient_0' , num2str(iNumberOfPatients), '.nii'];
    else
        fileName = [EXPORT_PATH , '/patient_' , num2str(iNumberOfPatients), '.nii'];
    end
    
    if postProcessingIsThresholding == true
        generatedNifti = make_nii(thresholdedProbabilityData{iNumberOfPatients}.img, [], [], datatype);
    else
        generatedNifti = make_nii(double(clusteredData{iNumberOfPatients}.img), [], [], datatype);
    end
    
    % Write mask header to probability data
    generatedNifti.hdr=originalMaskImages{iNumberOfPatients}.hdr;
    
    save_nii(generatedNifti, fileName);
    
end


% ++++++++++++++++++++++++++
% APPLY EVALUATION
% ++++++++++++++++++++++++++

system(['./../scripts_bash/ISLES_Evaluation.sh', ...
    ' ', ORIGINAL_DATA_PATH, ...
    ' ', PREDICTED_MASK_DATA, ...
    ' ', EVALUATION_BINARY ]);

meanEvaluationResults = ReadEvaluation('../../Output/Evaluation/');
dlmwrite(['../../Output/MeanEvaluationResults_' fileNameAppenedix '.txt'], meanEvaluationResults);

% end