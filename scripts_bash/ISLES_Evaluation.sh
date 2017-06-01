#!/bin/bash

#ORIGINAL_MASK_DATA="/data/data_l50b/ImageData/ISLES-challenge/SISS2015_Training/SISS2015/Training"
#PREDICTED_MASK_DATA="/data_l63/tsothman/Obelix/Output/predictedLesion"
#EVALUATION_BINARY="/data/data_l36/emuecke/Obelix/evaluation/ISLESevaluation/ImageValidationISLES"

ORIGINAL_MASK_DATA=$1
PREDICTED_MASK_DATA=$2
EVALUATION_BINARY=$3

OT_idx=0
OT_DATA_PATH=()
iterator=0
# mkdir ../../Output/Evaluation


for dir in "$ORIGINAL_MASK_DATA"/*
do
  SUBDIR_DATA_PATH="$dir"
	for file in "$SUBDIR_DATA_PATH"/*
	do
 	if [[ "$file" =~ 'OT' ]]; then
      for file in "$file"/*
      do
	if [[ "$file" =~ 'nii' ]]; then
	  OT_DATA_PATH[OT_idx]="$file"
	  OT_idx=$((OT_idx+1))
	fi
      done
    fi
  done
done


for file in "$PREDICTED_MASK_DATA"/*
do

OutputName=()
patientNumber=$((iterator+1))
OutputName="../../Output/Evaluation/Scores_Patient_$patientNumber"

echo "ISLES Evaluation for Patient" $patientNumber

# EXECUTING ISLES EVALUATION
executeISLESEvaluation="$EVALUATION_BINARY ${OT_DATA_PATH[$iterator]} $file $OutputName"

$executeISLESEvaluation

iterator=$((iterator+1))

done


exit
