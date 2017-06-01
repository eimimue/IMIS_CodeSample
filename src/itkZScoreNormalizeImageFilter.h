#ifndef __itkZScoreNormalizeImageFilter_h
#define __itkZScoreNormalizeImageFilter_h


#include <itkImageToImageFilter.h>
#include <itkNormalizeImageFilter.h>

namespace itk
{
template< typename TInputImage, typename TOutputImage >
class ZScoreNormalizeImageFilter:public ImageToImageFilter< TInputImage, TOutputImage >
{
public:

  /** Standard class typedefs. */
  typedef ZScoreNormalizeImageFilter                      Self;
  typedef ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef SmartPointer< Self >                            Pointer;

  /** Method for creation through the object factory. */
  itkNewMacro( Self );

  /** Run-time type information (and related methods). */
  itkTypeMacro( ZScoreNormalizeImageFilter, ImageToImageFilter );

  itkSetMacro( Variable, double );
  itkGetMacro( Variable, double );

  itkSetMacro( InputImageVector, std::vector< typename TInputImage::Pointer > );
  itkGetMacro( InputImageVector, std::vector< typename TInputImage::Pointer > );

protected:
  ZScoreNormalizeImageFilter(){}
  ~ZScoreNormalizeImageFilter(){}

  /** Does the real work. */
  virtual void GenerateData();

  double m_Variable;
  std::vector< typename TInputImage::Pointer > m_InputImageVector;

private:
  ZScoreNormalizeImageFilter(const Self &); //purposely not implemented
  void operator=(const Self &);  //purposely not implemented

};
} //namespace ITK


#ifndef ITK_MANUAL_INSTANTIATION
#include "itkZScoreNormalizeImageFilter.hxx"
#endif


#endif // __itkZScoreNormalizeImageFilter_h
