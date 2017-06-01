#ifndef __itkWrapperDiscreteGaussianImageFilter_hxx
#define __itkWrapperDiscreteGaussianImageFilter_hxx

#include "itkWrapperDiscreteGaussianImageFilter.h"
#include <itkObjectFactory.h>

//	#include <itkImageRegionIterator.h>
//	#include <itkImageRegionConstIterator.h>

namespace itk
{

template< class TInputImage, class TOutputImage >
void WrapperDiscreteGaussianImageFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename TInputImage::ConstPointer input = this->GetInput();
  typename TOutputImage::Pointer output = this->GetOutput();

  typename DiscreteGaussianImageFilter< TInputImage, TOutputImage >::Pointer discreteGaussianImageFilter;
  discreteGaussianImageFilter = DiscreteGaussianImageFilter< TInputImage, TOutputImage >::New();

  discreteGaussianImageFilter->SetInput( input );

  // set image spacing off to set 3mm blur fwhm
  discreteGaussianImageFilter->SetUseImageSpacingOff();

  const double gaussianVariance = 1.63; //var = (FWHM/2.35)**2 !TODO!

  discreteGaussianImageFilter->SetVariance( gaussianVariance );

  discreteGaussianImageFilter->Update();

  this->GraftOutput( discreteGaussianImageFilter->GetOutput() );
}

}// end namespace


#endif
