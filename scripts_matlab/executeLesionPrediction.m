% EXECUTE EVERYTHING

% --------------------------
% DEFINE PARAMETERS
% --------------------------

ICNS_RANDOMFORESTGUMP_BINARY='../../build/icnsRandomForestGump';
ORIGINAL_DATA_PATH='/Users/DGS/ownCloud/Obelix/Daten/ISLES-challenge/SISS2015_Training/SISS2015/Training';
OUTPUT_PATH='/Users/DGS/runObelixTest';
ModalityStrings = ['T1',     ...
                    '_'      ...
                    'T2',    ...
                    '_'      ...
                    'Flair', ...
                    '_'      ...
                    'DWI'    ...
                    '_'      ...
                    'OT'];


RANGER_BINARY='/Users/DGS/ranger/source/build/ranger';


% --------------------------
% Generate features
% --------------------------
TRAININGDATA_PATH=[OUTPUT_PATH, '/featureTables'];
TESTDATA_PATH=[OUTPUT_PATH, '/vectorizedImages'];

% mkdir(OUTPUT_PATH)

system(['./../scripts_bash/icnsRandomForestGump_generateFeatures.sh', ...
  ' ', ICNS_RANDOMFORESTGUMP_BINARY, ...
  ' ', ORIGINAL_DATA_PATH, ...
  ' ', OUTPUT_PATH, ...
  ' ', ModalityStrings]);


% generateFeatures
generateFeatures([OUTPUT_PATH])

leaveOneOut([OUTPUT_PATH, '/sampledFeatures/structTrainingData.mat'], OUTPUT_PATH);

convertImageDataToPredictorMatrix(OUTPUT_PATH)


% --------------------------
% Execute Ranger
% --------------------------
system(['./../scripts_bash/iterateRangerForAllPatients.sh', ...
  ' ', RANGER_BINARY, ...
  ' ', TRAININGDATA_PATH, ...
  ' ', TESTDATA_PATH, ...
  ' ', OUTPUT_PATH]);


% --------------------------
% Reshape prediction data to image
% --------------------------
convertRangerOutputToImage(OUTPUT_PATH, ORIGINAL_DATA_PATH);



% --------------------------
% Delete unnecessary folders
% --------------------------
