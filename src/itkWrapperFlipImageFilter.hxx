#ifndef __itkWrapperFlipImageFilter_hxx
#define __itkWrapperFlipImageFilter_hxx

#include "itkWrapperFlipImageFilter.h"
#include <itkObjectFactory.h>
#include <itkFixedArray.h>
#include <itkSubtractImageFilter.h>

//	#include <itkImageRegionIterator.h>
//	#include <itkImageRegionConstIterator.h>

namespace itk
{

template< class TInputImage, class TOutputImage >
void WrapperFlipImageFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename TInputImage::ConstPointer input = this->GetInput();
  typename TOutputImage::Pointer output = this->GetOutput();

  typename FlipImageFilter< TInputImage >::Pointer flipImageFilter;
  flipImageFilter = FlipImageFilter< TInputImage >::New();

  flipImageFilter->SetInput( input );

  FixedArray<bool, 3> flipAxes;
  flipAxes[0] = true;
  flipAxes[1] = false;
  flipAxes[2] = false;

  flipImageFilter->SetFlipAxes(flipAxes);

  flipImageFilter->Update();

  typename SubtractImageFilter< TInputImage, TInputImage, TOutputImage >::Pointer subtractImageFilter;
  subtractImageFilter = SubtractImageFilter< TInputImage, TInputImage, TOutputImage >::New();

  (flipImageFilter->GetOutput())->SetOrigin( input->GetOrigin() ); // TODO: Investigate Origin shift?!

  subtractImageFilter->SetInput1( flipImageFilter->GetOutput() );

  subtractImageFilter->SetInput2( input );



  subtractImageFilter->Update();

  this->GraftOutput( subtractImageFilter->GetOutput() );
}

}// end namespace


#endif
