#ifndef __ZScoreDeviationFilter_h
#define __ZScoreDeviationFilter_h

#include <itkImageToImageFilter.h>
#include <itkImageRegionConstIterator.h>
#include <itkGetAverageSliceImageFilter.h>
#include <itkExtractImageFilter.h>
#include <itkStatisticsImageFilter.h>
#include "itkImageRegionIterator.h"
#include "itkImageLinearConstIteratorWithIndex.h"
#include <itkJoinSeriesImageFilter.h>
#include <itkChangeInformationImageFilter.h>
#include <itkMultiplyImageFilter.h>
#include <itkDivideImageFilter.h>
#include <itkSubtractImageFilter.h>
#include <itkAddImageFilter.h>
#include <itkSqrtImageFilter.h>
#include <itkImageDuplicator.h>


namespace itk
{
template < typename TInputImage, typename TOutputImage >
class ZScoreDeviationFilter:public ImageToImageFilter <TInputImage, TOutputImage >
{
public:

  /** Standard class typedefs. */
  typedef ZScoreDeviationFilter                         Self;
  typedef ImageToImageFilter< TInputImage, TOutputImage >   Superclass;
  typedef SmartPointer< Self >                              Pointer;

  typedef float                                       ImagePixelType;
  typedef itk::Image<ImagePixelType, 3>               Image3DType;
  typedef itk::Image<ImagePixelType, 4>               Image4DType;

  /** Method for creation through the object factory. */
  itkNewMacro( Self );

  /** Run-time type information (and related methods). */
  itkTypeMacro( ZScoreDeviationFilter, ImageToImageFilter );

  itkSetMacro( Variable, double );
  itkGetMacro( Variable, double);

protected:
  ZScoreDeviationFilter(){}
  ~ZScoreDeviationFilter(){}

  /** Does the real work. */
  virtual void GenerateData();

  double m_Variable;

private:
  ZScoreDeviationFilter(const Self &); //purposely not implemented
  void operator=(const Self &);  //purposely not implemented

};
} //namespace ITK

#ifndef ITK_MANUAL_INSTANTIATION
#include "itkZScoreDeviationFilter.hxx"
#endif


#endif //
