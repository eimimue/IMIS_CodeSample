#ifndef __itkWrapperDiscreteGaussianImageFilter_h
#define __itkWrapperDiscreteGaussianImageFilter_h

#include <itkImageToImageFilter.h>
#include <itkDiscreteGaussianImageFilter.h>

namespace itk
{
template< typename TInputImage, typename TOutputImage >
class WrapperDiscreteGaussianImageFilter:public ImageToImageFilter< TInputImage, TOutputImage >
{
public:

  /** Standard class typedefs. */
  typedef WrapperDiscreteGaussianImageFilter                   Self;
  typedef ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef SmartPointer< Self >                            Pointer;

  /** Method for creation through the object factory. */
  itkNewMacro( Self );

  /** Run-time type information (and related methods). */
  itkTypeMacro( WrapperDiscreteGaussianImageFilter, ImageToImageFilter );

  itkSetMacro( Variable, double );
  itkGetMacro( Variable, double);

protected:
  WrapperDiscreteGaussianImageFilter(){}
  ~WrapperDiscreteGaussianImageFilter(){}

  /** Does the real work. */
  virtual void GenerateData();

  double m_Variable;

private:
  WrapperDiscreteGaussianImageFilter(const Self &); //purposely not implemented
  void operator=(const Self &);  //purposely not implemented

};
} //namespace ITK


#ifndef ITK_MANUAL_INSTANTIATION
#include "itkWrapperDiscreteGaussianImageFilter.hxx"
#endif


#endif // __itkWrapperDiscreteGaussianImageFilter_h
