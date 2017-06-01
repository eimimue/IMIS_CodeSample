#ifndef __itkZScoreNormalizeImageFilter_hxx
#define __itkZScoreNormalizeImageFilter_hxx

#include "itkZScoreNormalizeImageFilter.h"
#include <itkObjectFactory.h>
#include <itkImageRegionIterator.h>
#include <itkImageRegionConstIterator.h>

namespace itk
{

template< class TInputImage, class TOutputImage >
void ZScoreNormalizeImageFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename TInputImage::ConstPointer input = this->GetInput();
  typename TOutputImage::Pointer output = this->GetOutput();

  typename NormalizeImageFilter< TInputImage, TOutputImage >::Pointer normalizeImageFilter;
  normalizeImageFilter = NormalizeImageFilter< TInputImage, TOutputImage >::New();

  normalizeImageFilter->SetInput( input );
  normalizeImageFilter->Update();

  this->GraftOutput( normalizeImageFilter->GetOutput() );
}

}// end namespace


#endif
