#!/bin/bash
# Goal: Brief example for running cpp binaries.

# -----------------------------------------
# Define build path / input data / output path
# -----------------------------------------

if [ "$#" -ne 4 ]; then
  echo "Please call script with arguments: "
  echo "  #1: Path to binary of Obelix"
  echo "  #2: Original data path"
  echo "  #3: Desired export folder"
  echo "  #4: Search strings for modalities"
  exit 1
fi



# BUILD PATH:
ICNS_RANDOMFORESTGUMP_BINARY=$1
# BUILD_PATH="../../build"

# Input data:
# ORIGINAL_DATA_PATH="/data/data_l50b/ImageData/ISLES-challenge/SISS2015_Training/SISS2015/Training"
ORIGINAL_DATA_PATH=$2
# ORIGINAL_DATA_PATH="/Users/DGS/ownCloud/Obelix/Daten/ISLES-challenge/SISS2015_Training/SISS2015/Training"

# Results folder
OUTPUT_PATH=$3
#
EXPORT_PATH="$3/generatedFeatures"
mkdir $EXPORT_PATH

ModalityNames=$4


# -----------------------------------------
# EXECUTE
# -----------------------------------------

iNumberOfFolders=0
SUBDIR_DATA_PATH=()

# Return all subfolders in vector (SUBDIR_DATA_PATH)
# -----------------------------------------
for dir in "$ORIGINAL_DATA_PATH"/*
do
  SUBDIR_DATA_PATH[iNumberOfFolders]="$dir"
  iNumberOfFolders=$((iNumberOfFolders+1))
done


# Define number of image folders / modalities
# -----------------------------------------
numberOfImageFolders=$(find ${SUBDIR_DATA_PATH[0]} -mindepth 1 -type d | wc -l)

# Generate modality vector
# -----------------------------------------
for ((i=1;i<=$numberOfImageFolders;i++))
 do
   modalityName[$i]=$(echo $ModalityNames | cut -d'_' -f$i)
done


# Write filenames for individual modality in vector
# -----------------------------------------
iIterator=0

for ((i=1;i<=$numberOfImageFolders;i++))
do
  iIterator=0

  activeID=()
  activeID=$i

  for dir in "$ORIGINAL_DATA_PATH"/*
  do

    if [[ "${modalityName[$i]}" == 'OT' ]]; then
      mask[$iIterator]=$(find $dir -name '*'${modalityName[$i]}'*' -a -name '*.nii')

    else
    eval "Modality_$activeID[$iIterator]=$(find $dir -name '*'${modalityName[$i]}'*' -a -name '*.nii')"
    fi

    iIterator=$(($iIterator + 1 ))

  done

done


# Create folder for each patient
# -----------------------------------------
size=${#Modality_1[@]}

for ((i=1;i<=$size;i++)); do
  mkdir ${EXPORT_PATH}/Patient_${i}
  cp ${mask[i-1]} $EXPORT_PATH/Patient_${i}
done


# Output data:
# -----------------------------------------

featureData=="${DATA_PATH}/features.txt"

# -----------------------------------------
# Run RANDOMFORESTGUMP:
# -----------------------------------------

echo " "
echo "-- RUNNING RANDOMFORESTGUMP --"
echo " "

# Define featureExtractionCalls
# -----------------------------------------
for ((i=1;i<$numberOfImageFolders;i++)); do

  featureExtractionCall[$i]="$ICNS_RANDOMFORESTGUMP_BINARY \
  -I \
  $(eval echo \${Modality_$i[@]})
  -M \
  ${mask[@]}
  -v \
  -E \
  ${EXPORT_PATH}"

done

# Execute featureExtractionCalls
# -----------------------------------------
timeBefore=$(date +%s)

for ((i=1;i<$numberOfImageFolders;i++)); do
  ${featureExtractionCall[$i]}
done

timeAfter=$(date +%s)


# Display execution time
# -----------------------------------------
echo " "
echo "Elapsed time: " $((timeAfter - timeBefore)) "s"
echo " "

exit
