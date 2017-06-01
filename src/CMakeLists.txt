##############################################################################
#
# Filename: CMakeLists.txt for RandomForestGump project.
# Initial Author: Rene Werner
# Copyright (C) 2016 ICNS, UKE
#
##############################################################################

cmake_minimum_required(VERSION 2.4)
if(COMMAND CMAKE_POLICY)
  cmake_policy(SET CMP0003 NEW)
endif()

project(icnsRandomForestGump)

# Find ITK.
find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

# Set project sources:
set(RANDOMFORESTGUMP_SRCS
  icnsRandomForestGump.cxx
  itkZScoreNormalizeImageFilter.h
  itkZScoreNormalizeImageFilter.hxx
  itkWrapperDiscreteGaussianImageFilter.h
  itkWrapperDiscreteGaussianImageFilter.hxx
  itkWrapperFlipImageFilter.h
  itkWrapperFlipImageFilter.hxx
  itkZScoreDeviationFilter.h
  itkZScoreDeviationFilter.hxx
)

# Define make targets:
add_executable(icnsRandomForestGump ${RANDOMFORESTGUMP_SRCS})
target_link_libraries(icnsRandomForestGump ${ITK_LIBRARIES})
