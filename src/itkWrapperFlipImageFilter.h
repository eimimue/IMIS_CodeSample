#ifndef __itkWrapperFlipImageFilter_h
#define __itkWrapperFlipImageFilter_h

#include <itkImageToImageFilter.h>
#include <itkFlipImageFilter.h>
// #include <itkFixedArray.h>

namespace itk
{
template< typename TInputImage, typename TOutputImage >
class WrapperFlipImageFilter:public ImageToImageFilter< TInputImage, TOutputImage >
{
public:

  /** Standard class typedefs. */
  typedef WrapperFlipImageFilter                      	  Self;
  typedef ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef SmartPointer< Self >                            Pointer;

  /** Method for creation through the object factory. */
  itkNewMacro( Self );

  /** Run-time type information (and related methods). */
  itkTypeMacro( WrapperFlipImageFilter, ImageToImageFilter );

  itkSetMacro( Variable, double );
  itkGetMacro( Variable, double);

protected:
  WrapperFlipImageFilter(){}
  ~WrapperFlipImageFilter(){}

  /** Does the real work. */
  virtual void GenerateData();

  double m_Variable;

private:
  WrapperFlipImageFilter(const Self &); //purposely not implemented
  void operator=(const Self &);  //purposely not implemented

};
} //namespace ITK


#ifndef ITK_MANUAL_INSTANTIATION
#include "itkWrapperFlipImageFilter.hxx"
#endif


#endif // __itkWrapperFlipImageFilter_h
