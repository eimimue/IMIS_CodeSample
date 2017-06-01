#!/bin/bash

# RANGER_PATH="/Users/DGS/ranger/source/build"
# RANGER_BINARY="${RANGER_PATH}/ranger"
#
# TRAININGDATA_PATH="../scripts_matlab/resultsFolder/featureTables"
# TESTDATA_PATH="../scripts_matlab/resultsFolder/vectorizedImages"
# RANGER_PATH=$1
RANGER_BINARY=$1
TRAININGDATA_PATH=$2
TESTDATA_PATH=$3
EXPORT_PATH=$4


EXPORT_PATH="$EXPORT_PATH/PredictedImages"
mkdir $EXPORT_PATH
# EXECUTING RANGER TRAINING

echo " "
echo "-- EXECUTING RANGER --"
echo " "

timeInitial=$(date +%s)
echo $(date)
echo ""

for file in "$TRAININGDATA_PATH"/*
do
  timeBefore=$(date +%s)

  PATIENTNUMBER=$(echo $file | grep -o -E '[0-9]+')

  echo "Training Patient No. $PATIENTNUMBER"

  executeRangerTraining="$RANGER_BINARY \
  --probability \
  --file $file  \
  --depvarname lesion  \
  --treetype 1  \
  --ntree 100  \
  --nthreads 4  \
  --write \
  "

  $executeRangerTraining

  for file in "$TESTDATA_PATH"/*
  do

    PATIENTNUMBER_TEST=$(echo $file | grep -o -E '[0-9]+')

    if [[ "$PATIENTNUMBER" == "$PATIENTNUMBER_TEST" ]]; then


        echo "Predicting Patient No. $PATIENTNUMBER"
        echo ""

        executeRangerPrediction="$RANGER_BINARY \
        --file $file \
        --predict ranger_out.forest \
        "

        $executeRangerPrediction

        mkdir $EXPORT_PATH/Patient_$PATIENTNUMBER
        # mkdir ../../ObelixResults/Patient_$PATIENTNUMBER
        mv ranger_out.* $EXPORT_PATH/Patient_$PATIENTNUMBER


    fi

    done

    timeAfter=$(date +%s)
    timeCurrent=$(date)

    echo " "
    echo "Current time: " $timeCurrent
    echo "Elapsed time: " $((timeAfter - timeBefore)) "s"
    echo " "
    echo "----------------------"



done


echo " "
echo "Total elapsed time: " $((timeAfter - timeInitial)) "s"
echo " "


exit

# EXECUTING RANGER PREDICTION
