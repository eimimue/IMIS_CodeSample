/**
 * @file icnsRandomForestGump.cxx
 * This is the example main file for the ICNS project "RandomForestGump"
 * The project aims at ischemic stroke segmentation and the ISLES challenge.
 *
 * @brief Example main file for ICNS project RandomForestGump.
 *
 * @author Rene
 * @version 0.01
 */

// System includes:

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
extern "C"
{
#include "getopt.h"
}

// ITK includes:

#include <itkImage.h>
#include <itkImageFileReader.h>
#include <itkImageFileWriter.h>
#include <itkNormalizeImageFilter.h>
#include <itkJoinSeriesImageFilter.h>
#include <itkExtractImageFilter.h>

// Project includes:

#include "itkZScoreNormalizeImageFilter.h"
#include "itkWrapperDiscreteGaussianImageFilter.h"
#include "itkWrapperFlipImageFilter.h"
#include "itkZScoreDeviationFilter.h"

// Global typedefs: Sometimes useful. For instance, if additional
// functions (besides the main() function) are defined.

typedef short                                       ImagePixelType;
typedef itk::Image<ImagePixelType, 3>               ImageType;


typedef float                                       FeaturePixelType;
typedef itk::Image<FeaturePixelType, 3>             FeatureImageType;
typedef itk::Image<FeaturePixelType, 4>             Image4DType;

//typedef unsigned char                               SegmentationPixelType;
//typedef itk::Image<SegmentationPixelType, 3>        SegmentationImageType;

typedef itk::ImageFileReader<ImageType>             ImageFileReaderType;
//typedef itk::ImageFileReader<SegmentationImageType> SegmentationImageFileReaderType;

typedef itk::ImageFileWriter<ImageType>             ImageFileWriterType;
typedef itk::ImageFileWriter<FeatureImageType>      FeatureImageFileWriterType;


// ---------------------------------------------------------------
// Print help routine:
// ---------------------------------------------------------------

void PrintHelp()
{
  std::cout << "Usage:\n";
  std::cout << "icnsRandomForestGump -I <list of input images> -O <feature output file> ... \n";

  std::cout << std::endl;
  std::cout << "-I  <list of input images>           Filenames of input images (any itk readable file format OK).\n";
//  std::cout << "-M  <list of mask images>            Filenames of lesion masks.\n";
  std::cout << "-O  <feature output file>            Filename for output features (written as ascii).\n";

  std::cout << std::endl;
  std::cout << "Further parameters:\n";
  std::cout << "-v                                   Verbose mode. Writing, e.g., individual feature images to disk.\n";
  std::cout << "-h                                   Print this help.\n\n";
}


// ---------------------------------------------------------------
// Main routine:
// ---------------------------------------------------------------

int main( int argc, char *argv[] )
{
  // Check if arguments were passed or not:

  if( argc < 3 )
  {
    PrintHelp();
    return EXIT_FAILURE;
  }

  std::cout << "========================================" << std::endl;
  std::cout << "icnsRandomForestGump" << std::endl;
  std::cout << "----------------------------------------" << std::endl;
  std::cout << "Reading parameters ..." << std::endl;

  // Initialize parameters with default values:

  bool verboseMode = false;

  // In this case: As it is not clear, how many images are to be processed,
  // std vectors are used to read and internally store the images.
  // It makes sense to provide a vector for each feature.

  std::vector<std::string>                    inputFLAIRImageFilenames;
//  std::vector<std::string>                    inputLesionSegmentationImageFilenames;
  std::string                                 outputFeatureFilename;

  std::vector<ImageType::Pointer>             inputFLAIRImages;
//std::vector<SegmentationImageType::Pointer> inputLesionSegmentationImages;

  std::vector<FeatureImageType::Pointer>      feature1Images;
  std::vector<FeatureImageType::Pointer>      feature2Images;
  std::vector<FeatureImageType::Pointer>      feature3Images;
  std::vector<FeatureImageType::Pointer>      feature4Images;

  std::string   exportFolderName;

  // Reading parameters:

  char c;
  int counter = 0;

  while( (c = getopt( argc, argv, "I:E:o:vh?" )) != -1 )
  {
    switch( c )
    {
      case 'I':
        // Reads input filenames as long as the next signs are not ' -':
        std::cout << "Input images: " << std::endl;
        optind--;
        counter = 0;
        for( ; optind < argc && *argv[optind] != '-'; optind++, counter++ )
        {
          inputFLAIRImageFilenames.push_back( argv[optind] );
          std::cout << "-> Image [" << counter << "]:       " << argv[optind] << std::endl;
        }
        break;
/*	
	case 'M':
        // Reads lesion mask filenames as long as the next signs are not ' -':
        std::cout << "Lesion images: " << std::endl;
        optind--;
        counter = 0;
        for( ; optind < argc && *argv[optind] != '-'; optind++, counter++ )
        {
          inputLesionSegmentationImageFilenames.push_back( argv[optind] );
          std::cout << "-> Lesion mask [" << counter << "]: " << argv[optind] << std::endl;
        }
        break; 
*/
      case 'E':
          std::cout << "Export Folder: " << std::endl;
          optind--;
          exportFolderName = argv[optind];
          std::cout << exportFolderName << std::endl;
          break;
      case 'O':
        optind--;
        outputFeatureFilename = argv[optind];
        std::cout << "Output feature filename: " << outputFeatureFilename << std::endl;
        break;
      case 'v':
        verboseMode = true;
        std::cout << "Verbose mode: ON." << std::endl;
        break;
      case 'h':
      case '?':
        PrintHelp();
        return EXIT_SUCCESS;
        break;
      default:
        std::cerr << "Argument "<<(char)c<<" not processed!\n" << std::endl;
        break;
    }
  }

  // Running plausibility checks:

  if( inputFLAIRImageFilenames.empty() )
  {
    std::cerr << "At least a single images name required!\n" << std::endl;
    return EXIT_FAILURE;
  }

/*
  if( inputFLAIRImageFilenames.size() != inputLesionSegmentationImageFilenames.size() )
  {
    std::cerr << "Number of input filenames has to be identical for all image modalities!\n" << std::endl;
    return EXIT_FAILURE;
  }
*/

  // -------------------------------------------------------------
  // Loading input images.
  // First: FLAIR images:

  ImageFileReaderType::Pointer inputImageReader;
//  SegmentationImageFileReaderType::Pointer inputSegmentationImageReader;

  std::cout << "----------------------------------------" << std::endl;
  std::cout << "Loading input images ... " << std::endl;

  for( unsigned int iFLAIRImages = 0; iFLAIRImages < inputFLAIRImageFilenames.size(); iFLAIRImages++ )
  {
    ImageType::Pointer inputImage;
    inputImageReader = ImageFileReaderType::New();
    inputImageReader->SetFileName( inputFLAIRImageFilenames[iFLAIRImages].c_str() );
    inputImage = inputImageReader->GetOutput();
    inputImage->Update();

    inputImage->DisconnectPipeline();
    inputFLAIRImages.push_back( inputImage );
  }

 /* for( unsigned int iLesionSegmentationImages = 0; iLesionSegmentationImages < inputLesionSegmentationImageFilenames.size(); iLesionSegmentationImages++ )
  {
    SegmentationImageType::Pointer inputSegmentationImage;
    inputSegmentationImageReader = SegmentationImageFileReaderType::New();
    inputSegmentationImageReader->SetFileName( inputLesionSegmentationImageFilenames[iLesionSegmentationImages].c_str() );
    inputSegmentationImage = inputSegmentationImageReader->GetOutput();
    inputSegmentationImage->Update();

    inputSegmentationImage->DisconnectPipeline();
    inputLesionSegmentationImages.push_back( inputSegmentationImage );
  }*/

  // -------------------------------------------------------------
  // Computing feature images: NYI

  // 1.) For each image, generate the corresponding z-score
  // normalized image:

  std::cout << "----------------------------------------" << std::endl;
  std::cout << "Generating feature 1: z-score normalized intensities" << std::endl;
  std::cout << "Generating feature 2: z-score deviation" << std::endl;
  std::cout << "Generating feature 3: discrete gaussian blurred image" << std::endl;
  std::cout << "Generating feature 4: flip gaussian blurred image and subtract feature 3 image" << std::endl;
  /*
  typedef itk::NormalizeImageFilter<ImageType,FeatureImageType> NormalizeImageFilterType;
  NormalizeImageFilterType::Pointer normalizeImageFilter;

  for( unsigned int iFLAIRImages = 0; iFLAIRImages < inputFLAIRImages.size(); iFLAIRImages++ )
  {
    FeatureImageType::Pointer featureImage;
    normalizeImageFilter = NormalizeImageFilterType::New();
    normalizeImageFilter->SetInput( inputFLAIRImages[iFLAIRImages] );
    featureImage = normalizeImageFilter->GetOutput();
    featureImage->Update();

    featureImage->DisconnectPipeline();
    feature1Images.push_back( featureImage );
  }
  */

  // The above version works fine. However, for educational reasons, I
  // also included a derived filter that does the same (actually: is a
  // wrapper around the itkNormalizeImageFilter) -- but illustrates things
  // like classes and inheritance.
  // Todo: Add comments to class.

  typedef itk::ZScoreNormalizeImageFilter<ImageType,FeatureImageType> NormalizeImageFilterType;
  NormalizeImageFilterType::Pointer normalizeImageFilter;


  typedef itk::WrapperDiscreteGaussianImageFilter<ImageType,FeatureImageType> DiscreteGaussianFilterType;
  DiscreteGaussianFilterType::Pointer discreteGaussianFilter;


  typedef itk::WrapperFlipImageFilter<FeatureImageType,FeatureImageType> FlipImageFilterType;
  FlipImageFilterType::Pointer flipImageFilter;


  for( unsigned int iFLAIRImages = 0; iFLAIRImages < inputFLAIRImages.size(); iFLAIRImages++ )
  {
    FeatureImageType::Pointer featureImage;
    //ImageType::Pointer feature4Image;

    normalizeImageFilter = NormalizeImageFilterType::New();
    normalizeImageFilter->SetInput( inputFLAIRImages[iFLAIRImages] );
    featureImage = normalizeImageFilter->GetOutput();
    featureImage->Update();

    featureImage->DisconnectPipeline();
    feature1Images.push_back( featureImage );


    discreteGaussianFilter = DiscreteGaussianFilterType::New();
    discreteGaussianFilter->SetInput( inputFLAIRImages[iFLAIRImages] );
    featureImage = discreteGaussianFilter->GetOutput();
    featureImage->Update();

    featureImage->DisconnectPipeline();
    feature3Images.push_back( featureImage );


    flipImageFilter = FlipImageFilterType::New();
    flipImageFilter->SetInput( feature3Images[iFLAIRImages] );
    featureImage = flipImageFilter->GetOutput();
    featureImage->Update();

    featureImage->DisconnectPipeline();
    feature4Images.push_back( featureImage );

  }

  // -------------------------------------------------------------
  // Generating 4D image from 3D images
  // -------------------------------------------------------------
  Image4DType::Pointer wholeImage;
  typedef itk::JoinSeriesImageFilter<FeatureImageType, Image4DType > JoinSeriesImageType;
  JoinSeriesImageType::Pointer joinSeriesImage = JoinSeriesImageType::New();

  for ( unsigned int iFeature1Images = 0; iFeature1Images < feature1Images.size(); iFeature1Images++ )
  {
    joinSeriesImage->SetInput(iFeature1Images, feature1Images[iFeature1Images]);
  }
  joinSeriesImage->Update();

  wholeImage = joinSeriesImage->GetOutput();


  // -------------------------------------------------------------
  // Generating feature 2
  // -------------------------------------------------------------
  typedef itk::ZScoreDeviationFilter<Image4DType,Image4DType> ZScoreDeviationFilterType;
  ZScoreDeviationFilterType::Pointer zScoreDeviationFilter;

  zScoreDeviationFilter = ZScoreDeviationFilterType::New();

  zScoreDeviationFilter->SetInput( wholeImage );

  Image4DType::Pointer feature2Image4D;
  feature2Image4D = zScoreDeviationFilter->GetOutput();
  feature2Image4D->Update();
  feature2Image4D->DisconnectPipeline();

  // -------------------------------------------------------------
  // Generating 3D images from 4D image
  // -------------------------------------------------------------


  typedef itk::ExtractImageFilter<Image4DType, FeatureImageType> ExtractImageFilterType;
  ExtractImageFilterType::Pointer extractImageFilter;

  extractImageFilter = ExtractImageFilterType::New();
  extractImageFilter->SetInput( feature2Image4D );
  extractImageFilter->SetDirectionCollapseToSubmatrix();

  Image4DType::RegionType inputRegionFeature2 = feature2Image4D->GetLargestPossibleRegion();

  Image4DType::SizeType sizeFeature2 = inputRegionFeature2.GetSize();
  Image4DType::IndexType start = inputRegionFeature2.GetIndex();

  // std::cout << "originalsize: " << inputRegionFeature2.GetSize(3) << std::endl;
  // std::vector<FeatureImageType::Pointer> input3Dimages;
  Image4DType::RegionType desiredRegion;
  FeatureImageType::Pointer extractedImage;

  sizeFeature2[3]  =  0;
  desiredRegion.SetSize( sizeFeature2 );

  for ( unsigned int iNumberOfPatients = 0; iNumberOfPatients < inputRegionFeature2.GetSize(3); iNumberOfPatients++)
  {
    start[3] = iNumberOfPatients;
    desiredRegion.SetIndex( start );
    extractImageFilter->SetExtractionRegion( desiredRegion );
    extractImageFilter->Update();
    extractedImage = extractImageFilter->GetOutput();

    extractedImage->DisconnectPipeline();
    feature2Images.push_back( extractedImage );
  }

  // feature2Images.push_back( averageSlice );
  // std::cout << "feature2Images: " <<  feature2Images.size() << std::endl;


  std::cout << "OK." << std::endl;

  // -------------------------------------------------------------
  // Writing output data.
  // First step: writing output feature data: NYI.

  std::cout << "----------------------------------------" << std::endl;
  std::cout << "Writing output feature data: NYI." << std::endl;

  // Second step: if verbose mode is enabled, write generated
  // feature images. If so, add a corresponding postfix to the original
  // image name.

  if( verboseMode )
  {
    std::cout << "Writing generated feature images ... " << std::endl;

    for( unsigned int iFeature1Images = 0; iFeature1Images < feature1Images.size(); iFeature1Images++ )
    {
      // Generate output filenames (with special handling for
      // packed nii data):

      std::string currentFilename = inputFLAIRImageFilenames[iFeature1Images];

      std::string::size_type lastPointInFilename = currentFilename.rfind('.');
      std::string filenameExtension = currentFilename.substr( lastPointInFilename+1 );
      if( filenameExtension == "gz" )
      {
        filenameExtension = "nii.gz";
        lastPointInFilename -= 4;
      }
      std::string filenameBase = currentFilename.substr( 0, lastPointInFilename );


      unsigned int a = filenameBase.rfind('.');
      unsigned int b = filenameBase.rfind('/');
      std::string individualFileName = filenameBase.substr(b+1,a);
      std::string folderName = filenameBase.substr(0,b);

      std::ostringstream oss;
      oss << exportFolderName << "/Patient_" << iFeature1Images+1 << "/" << individualFileName;
      std::string combinedString = oss.str();

      filenameBase = combinedString;

      // ------------------------------------------------- FEATURE 1

      std::string outputImageFilename = filenameBase + "_feature1." + filenameExtension;


      // Write images to file:

      FeatureImageFileWriterType::Pointer imageWriter = FeatureImageFileWriterType::New();
      imageWriter->SetInput( feature1Images[iFeature1Images] );
      imageWriter->SetFileName( outputImageFilename );

      try
      {
        imageWriter->Update();
      }
      catch( itk::ExceptionObject& excp )
      {
        std::cerr << "ERROR while writing output image." << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
      }


      // ------------------------------------------------- FEATURE 2

      std::string outputImageFilenameFeature2 = filenameBase + "_feature2." + filenameExtension;

      // Write images to file:

      FeatureImageFileWriterType::Pointer imageWriterFeature2 = FeatureImageFileWriterType::New();
      imageWriterFeature2->SetInput( feature2Images[iFeature1Images] );
      imageWriterFeature2->SetFileName( outputImageFilenameFeature2 );

      try
      {
        imageWriterFeature2->Update();
      }
      catch( itk::ExceptionObject& excp )
      {
        std::cerr << "ERROR while writing output image." << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
      }

      // ------------------------------------------------- FEATURE 3

      std::string outputImageFilenameFeature3 = filenameBase + "_feature3." + filenameExtension;

      // Write images to file:

      FeatureImageFileWriterType::Pointer imageWriterFeature3 = FeatureImageFileWriterType::New();
      imageWriterFeature3->SetInput( feature3Images[iFeature1Images] );
      imageWriterFeature3->SetFileName( outputImageFilenameFeature3 );

      try
      {
        imageWriterFeature3->Update();
      }
      catch( itk::ExceptionObject& excp )
      {
        std::cerr << "ERROR while writing output image." << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
      }

      // ------------------------------------------------- FEATURE 4

      std::string outputImageFilenameFeature4 = filenameBase + "_feature4." + filenameExtension;

      // Write images to file:

      FeatureImageFileWriterType::Pointer imageWriterFeature4 = FeatureImageFileWriterType::New();
      imageWriterFeature4->SetInput( feature4Images[iFeature1Images] );
      imageWriterFeature4->SetFileName( outputImageFilenameFeature4 );

      try
      {
        imageWriterFeature4->Update();
      }
      catch( itk::ExceptionObject& excp )
      {
        std::cerr << "ERROR while writing output image." << std::endl;
        std::cerr << excp << std::endl;
        return EXIT_FAILURE;
      }
    }

    std::cout << "OK." << std::endl;
  }

  std::cout << "----------------------------------------" << std::endl;

  return EXIT_SUCCESS;

}
