#ifndef __icnsZScoreDeviation_hxx
#define __icnsZScoreDeviation_hxx

#include "itkZScoreDeviationFilter.h"
#include <itkObjectFactory.h>

namespace itk
{

template <class TInputImage, class TOutputImage >
void ZScoreDeviationFilter <TInputImage, TOutputImage>
::GenerateData()
{
  typename TInputImage::ConstPointer input = this->GetInput();
  typename TOutputImage::Pointer output = this->GetOutput();

  // -------------------------------------------------------------
  // Extract 3D images from 4D input image
  // -------------------------------------------------------------
  typename ExtractImageFilter< TInputImage, Image3DType >::Pointer extractImageFilter;
  extractImageFilter = ExtractImageFilter< TInputImage, Image3DType >::New();

  extractImageFilter->SetInput( input );
  extractImageFilter->SetDirectionCollapseToSubmatrix();

  typename TInputImage::RegionType inputRegion = input->GetLargestPossibleRegion();

  typename TInputImage::SizeType size = inputRegion.GetSize();
  typename TInputImage::IndexType start = inputRegion.GetIndex();

  // std::cout << "originalsize: " << inputRegion.GetSize(3) << std::endl;
  std::vector<Image3DType::Pointer> input3Dimages;
  typename TInputImage::RegionType desiredRegion;
  Image3DType::Pointer extractedImage;

  size[3]  =  0;
  desiredRegion.SetSize( size );

  for ( unsigned int iNumberOfPatients = 0; iNumberOfPatients < inputRegion.GetSize(3); iNumberOfPatients++)
  {
    start[3] = iNumberOfPatients;
    desiredRegion.SetIndex( start );
    extractImageFilter->SetExtractionRegion( desiredRegion );
    extractImageFilter->Update();
    extractedImage = extractImageFilter->GetOutput();
    extractedImage->DisconnectPipeline();

    input3Dimages.push_back( extractedImage );
  }

  // -------------------------------------------------------------
  // Average the 4D image across the fourth dimension
  // -------------------------------------------------------------

    typedef unsigned char               PixelType;

    Image3DType::Pointer image3D = Image3DType::New();
    typedef Image3DType::IndexType    Index3DType;
    typedef Image3DType::SizeType     Size3DType;
    typedef Image3DType::RegionType   Region3DType;
    typedef Image3DType::SpacingType  Spacing3DType;
    typedef Image3DType::PointType    Origin3DType;
    typedef Image4DType::IndexType    Index4DType;
    typedef Image4DType::SizeType     Size4DType;
    typedef Image4DType::SpacingType  Spacing4DType;
    typedef Image4DType::PointType    Origin4DType;
  // Software Guide : EndCodeSnippet
    Index3DType       index3D;
    Size3DType        size3D;
    Spacing3DType     spacing3D;
    Origin3DType      origin3D;
    Image4DType::RegionType region4D = input->GetBufferedRegion();
    Index4DType       index4D   = region4D.GetIndex();
    Size4DType        size4D    = region4D.GetSize();
    Spacing4DType     spacing4D = input->GetSpacing();
    Origin4DType      origin4D  = input->GetOrigin();

    for( unsigned int i=0; i < 3; i++)
      {
      size3D[i]    = size4D[i];
      index3D[i]   = index4D[i];
      spacing3D[i] = spacing4D[i];
      origin3D[i]  = origin4D[i];
      }
    image3D->SetSpacing( spacing3D );
    image3D->SetOrigin(  origin3D  );
    Region3DType region3D;
    region3D.SetIndex( index3D );
    region3D.SetSize( size3D );
    image3D->SetRegions( region3D  );
    image3D->Allocate();

    typedef itk::NumericTraits< PixelType >::AccumulateType    SumType;
    typedef itk::NumericTraits< SumType   >::RealType          MeanType;
    const unsigned int timeLength = region4D.GetSize()[3];
    typedef itk::ImageLinearConstIteratorWithIndex<
                                    Image4DType > IteratorType;


    IteratorType it( input, region4D );
    it.SetDirection( 3 ); // Walk along time dimension
    it.GoToBegin();
    while( !it.IsAtEnd() )
      {
      SumType sum = itk::NumericTraits< SumType >::ZeroValue();
      it.GoToBeginOfLine();
      index4D = it.GetIndex();
      while( !it.IsAtEndOfLine() )
        {
        sum += it.Get();
        ++it;
        }
      MeanType mean = static_cast< MeanType >( sum ) /
                      static_cast< MeanType >( timeLength );
      index3D[0] = index4D[0];
      index3D[1] = index4D[1];
      index3D[2] = index4D[2];
      image3D->SetPixel( index3D, static_cast< PixelType >( mean ) );
      it.NextLine();
      }


  // -------------------------------------------------------------
  // Average the 4D image across the fourth dimension
  // -------------------------------------------------------------

  typename GetAverageSliceImageFilter< TInputImage, Image4DType >::Pointer getAverageSliceImage;
  getAverageSliceImage = GetAverageSliceImageFilter< TInputImage, Image4DType >::New();

  getAverageSliceImage ->SetInput( input );
  getAverageSliceImage ->SetAveragedOutDimension( 4 );

  Image4DType::Pointer averaged4DImage;
  averaged4DImage = getAverageSliceImage->GetOutput();
  averaged4DImage ->Update();
  averaged4DImage ->DisconnectPipeline();

  // -------------------------------------------------------------
  // Extract the averaged slice
  // -------------------------------------------------------------
  extractImageFilter->SetInput( averaged4DImage );
  // extractImageFilter->SetDirectionCollapseToSubmatrix();
  // extractImageFilter->SetDirectionCollapseToIdentity();
  extractImageFilter->SetDirectionCollapseToGuess();

  size[3]  = 0;
  start[3] = 0;

  desiredRegion.SetSize( size );
  desiredRegion.SetIndex( start );

  extractImageFilter->SetExtractionRegion( desiredRegion );
  extractImageFilter->Update();

  Image3DType::Pointer averaged3DImage;
  averaged3DImage = extractImageFilter->GetOutput();
  averaged3DImage->DisconnectPipeline();
  // averaged3DImage->SetOrigin(input3Dimages[0]->GetOrigin() );

  typedef itk::ChangeInformationImageFilter< Image3DType >  ChangeInformationImageFilterType;
  ChangeInformationImageFilterType::Pointer changeInformationImageFilter = ChangeInformationImageFilterType::New();

  Image3DType::DirectionType direction = input3Dimages[0]->GetDirection();

  changeInformationImageFilter->SetOutputDirection( direction );
  changeInformationImageFilter->ChangeDirectionOn();
  // changeInformationImageFilter->SetInput( averaged3DImage );
  changeInformationImageFilter->SetInput( image3D );
  changeInformationImageFilter->Update();

  // -------------------------------------------------------------
  // Substract 3D images from the averaged slice
  // -------------------------------------------------------------
  typename SubtractImageFilter< Image3DType, Image3DType >::Pointer subtractImage;
  subtractImage = SubtractImageFilter< Image3DType, Image3DType >::New();

  subtractImage->SetInput1( changeInformationImageFilter->GetOutput() );

  Image3DType::Pointer subtractedImages;
  std::vector<Image3DType::Pointer> subtracted3DVector;

  for ( unsigned int iNumberOfPatients = 0; iNumberOfPatients < inputRegion.GetSize(3); iNumberOfPatients++)
  {
    // subtractImage->SetInput1( input3Dimages[iNumberOfPatients] );
    subtractImage->SetInput2(input3Dimages[iNumberOfPatients]);
    subtractedImages = subtractImage->GetOutput();
    subtractedImages->Update();
    subtractedImages->DisconnectPipeline();
    subtracted3DVector.push_back( subtractedImages );
  }

  // -------------------------------------------------------------
  // Generate std
  // -------------------------------------------------------------
  typedef itk::MultiplyImageFilter <Image3DType, Image3DType >
     MultiplyImageFilterType;
     MultiplyImageFilterType::Pointer multiplyFilter = MultiplyImageFilterType::New ();

     Image3DType::Pointer multiplicated3D;
     std::vector<Image3DType::Pointer> multiplicated3DVector;

     for ( unsigned int iNumberOfPatients = 0; iNumberOfPatients < inputRegion.GetSize(3); iNumberOfPatients++)
     {
       multiplyFilter->SetInput1(subtracted3DVector[iNumberOfPatients]);
       multiplyFilter->SetInput2(subtracted3DVector[iNumberOfPatients]);
       multiplicated3D = multiplyFilter->GetOutput();
       multiplicated3D -> Update();
       multiplicated3D -> DisconnectPipeline();

       multiplicated3DVector.push_back(multiplicated3D);
     }

     typedef itk::AddImageFilter <Image3DType, Image3DType >
        AddImageFilterType;
        AddImageFilterType::Pointer addFilter = AddImageFilterType::New ();

        Image3DType::Pointer summedMultiplicated3D;

        // typedef itk::ImageDuplicator< Image3DType > DuplicatorType;
        // DuplicatorType::Pointer duplicator = DuplicatorType::New();
        //
        // duplicator->SetInputImage(multiplicated3D);
        // summedMultiplicated3D = duplicator->GetModifiableOutput();
        // summedMultiplicated3D->Update();
        // // summedMultiplicated3D->DisconnectPipeline();
        // TODO: this is a little bit stupid.....
        summedMultiplicated3D = multiplicated3DVector[0];

        for ( unsigned int iNumberOfPatients = 1; iNumberOfPatients < inputRegion.GetSize(3); iNumberOfPatients++)
        {
          addFilter->SetInput1(summedMultiplicated3D);
          addFilter->SetInput2(multiplicated3DVector[iNumberOfPatients]);
          summedMultiplicated3D = addFilter->GetOutput();
          summedMultiplicated3D -> Update();
          summedMultiplicated3D -> DisconnectPipeline();
        }

  // -------------------------------------------------------------
  // Generate template matrix with std
  // -------------------------------------------------------------
  Image3DType::IndexType startTemplateImage;
  Image3DType::SizeType sizeTemplateImage;
  Image3DType::RegionType regionTemplateImage;

  startTemplateImage[0] = 0;
  startTemplateImage[1] = 0;
  startTemplateImage[2] = 0;

  typename Image3DType::RegionType inputRegion3D = subtracted3DVector[0]->GetLargestPossibleRegion();

  sizeTemplateImage[0] = inputRegion3D.GetSize(0);
  sizeTemplateImage[1] = inputRegion3D.GetSize(1);
  sizeTemplateImage[2] = inputRegion3D.GetSize(2);

  regionTemplateImage.SetSize(sizeTemplateImage);
  regionTemplateImage.SetIndex(startTemplateImage);

  // Image3DType::Pointer templateStdImage = Image3DType::New();

  typedef itk::ImageDuplicator< Image3DType > DuplicatorType;
  DuplicatorType::Pointer duplicator = DuplicatorType::New();

  duplicator->SetInputImage(subtracted3DVector[0]);
  duplicator->Update();
  Image3DType::Pointer templateStdImage = duplicator->GetOutput();

  itk::ImageRegionIterator<Image3DType> imageIterator(templateStdImage,regionTemplateImage);
  while(!imageIterator.IsAtEnd())
  {
  // Set the current pixel to white
  imageIterator.Set( inputRegion.GetSize(3) );
  ++imageIterator;
  }

  // -------------------------------------------------------------
  // Divide by n-1
  // -------------------------------------------------------------
  typedef DivideImageFilter<Image3DType, Image3DType, Image3DType> DivideImageFilterType;
  DivideImageFilterType::Pointer divideImageFilter = DivideImageFilterType::New();

  Image3DType::Pointer varianceImage;

  divideImageFilter->SetInput1(summedMultiplicated3D);
  divideImageFilter->SetInput2(templateStdImage);
  varianceImage = divideImageFilter->GetOutput();
  varianceImage->Update();
  varianceImage->DisconnectPipeline();

  // -------------------------------------------------------------
  // ^(1/2)
  // -------------------------------------------------------------
  typedef SqrtImageFilter<Image3DType, Image3DType> SqrtImageFilterType;
  SqrtImageFilterType::Pointer sqrtImageImageFilter = SqrtImageFilterType::New();

  Image3DType::Pointer stdImage;
  sqrtImageImageFilter->SetInput( varianceImage );

  stdImage = sqrtImageImageFilter->GetOutput();
  stdImage -> Update();
  stdImage->DisconnectPipeline();

  // -------------------------------------------------------------
  // Divide by std
  // -------------------------------------------------------------
  Image3DType::Pointer dividedImages;
  std::vector<Image3DType::Pointer> divided3DVector;

  divideImageFilter->SetInput1(templateStdImage);

  for ( unsigned int iNumberOfPatients = 0; iNumberOfPatients < inputRegion.GetSize(3); iNumberOfPatients++ )
  {
    divideImageFilter->SetInput2(subtracted3DVector[iNumberOfPatients]);
    dividedImages = divideImageFilter->GetOutput();
    dividedImages->Update();
    dividedImages->DisconnectPipeline();

    divided3DVector.push_back( dividedImages );
  }


  // -------------------------------------------------------------
  // Append 3D images to 4D image
  // -------------------------------------------------------------
  Image4DType::Pointer feature2Image4D;
  typedef itk::JoinSeriesImageFilter<Image3DType, Image4DType > JoinSeriesImageType;
  JoinSeriesImageType::Pointer joinSeriesImage = JoinSeriesImageType::New();

  for ( unsigned int iNumberOfPatients = 0; iNumberOfPatients < subtracted3DVector.size(); iNumberOfPatients++ )
  {
    joinSeriesImage->SetInput(iNumberOfPatients, divided3DVector[iNumberOfPatients]);
  }
  joinSeriesImage->Update();

  feature2Image4D = joinSeriesImage->GetOutput();


  // -------------------------------------------------------------
  // Export 4D image
  // -------------------------------------------------------------
  this->GraftOutput( feature2Image4D );
}


}


#endif
