
# RF-Classification
Segmentation of Stroke Lesions using Random Forest Classification.

### Table of Contents
1. [About](#about)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Install dependencies](#dependencies)


## About
Current implementation of this script is based on [Halme, H. et al., 2015](http://www.isles-challenge.org/ISLES2015/articles/halmh1.pdf).

**Basic algorithm**
- Feature generation
  1. Z-score normalized voxel intensities
  1. Z-score deviation from global average images
  1. Gaussian smoothing
  1. Local asymmetry
- Classifier training using Random forest (tool: ranger).
- Contextual clustering


## Installation

**Install Obelix**
```bash
git clone https://github.com/eimimue/IMIS_CodeSample.git
mkdir build && cd build
cmake ../src
make -j4
```
**Dependencies**

(for installation routines, see [last section](#dependencies))
- ITK 4.9
- [Ranger (Implementation of Random Forests)](https://github.com/imbs-hl/ranger)
- Matlab
- Unix based infrastructure


## Usage

Open `executeLesionPrediction.m` and change the following parameters:

- ICNS_RANDOMFORESTGUMP_BINARY: Path to binary
- ORIGINAL_DATA_PATH: Path to image data
- OUTPUT_PATH: Export folder

- RANGER_BINARY: Path to ranger binary

After the parameters have been set, execute `executeLesionPrediction.m`.

The image data should be sorted in a file structured as seen below.

```
DATA_PATH
|
|__ Patient_1
|   |__Modality_1
|   |   Image data
|   |__Modality_2
|   |   Image data
|   |__Modality_3
|   |   Image data
|   |Mask
|   |   Image data
|
|__ Patient_2
|   |__Modality_1
|   |   Image data
|   |__Modality_2
|   |   Image data
|   |__Modality_3
|   |   Image data
|   |Mask
|   |   Image data
|
|__ Patient n
|
```

## Dependencies

#### ITK 4.9
```bash
git clone -b v4.9.0  https://itk.org/ITK.git ITK-4.9.0
cd ITK-4.9.0
mkdir bin && cd bin
cmake ..
make -j4 && make install
```

#### Ranger

```bash
git clone https://github.com/imbs-hl/ranger.git
cd ranger/source
mkdir build && cd build
cmake ..
make -j4
```

#### ISLES Evaluation Script

```bash
git clone https://github.com/loli/ISLESevaluation
cd ISLESevaluation
mkdir build && cd build
cmake ..
make -j4
```
