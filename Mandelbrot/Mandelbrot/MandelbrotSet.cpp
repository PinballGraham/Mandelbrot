//
//  MandelbrotSet.cpp
//  Mandelbrot
//
//  Created by Graham West on 11/4/13.
//  Copyright (c) 2013 Graham West. All rights reserved.
//

#include <vector>

#include "MandelbrotSet.h"

MandelbrotSet::MandelbrotSet(double originReal, double originImaginary, double endReal, double endImaginary,
	unsigned int width, unsigned int height, unsigned int maxIterations)
{
	m_originReal = originReal;
	m_originImaginary = originImaginary;
	m_realRange = endReal - originReal;
	m_imaginaryRange = endImaginary - originImaginary;
	m_width = width;
	m_height = height;
	m_maxIterations = maxIterations;
	m_fewestIterations = maxIterations;
	m_mostIterations = 0;

	if (m_width == 0)
	{
		m_width = 1;
	}
	
	if (m_height == 0)
	{
		m_height = 1;
	}
	
	if (m_maxIterations == 0)
	{
		m_maxIterations = 1;
	}
}

MandelbrotSet::~MandelbrotSet()
{
}

MandelbrotSet::MandelbrotSet(const MandelbrotSet& src)
{
	m_originReal = src.m_originReal;
	m_originImaginary = src.m_originImaginary;
	m_realRange = src.m_realRange;
	m_imaginaryRange = src.m_imaginaryRange;
	m_width = src.m_width;
	m_height = src.m_height;
	m_maxIterations = src.m_maxIterations;
}

MandelbrotSet& MandelbrotSet::operator=(const MandelbrotSet& src)
{
	return *this;
}

MandelbrotSet::Result MandelbrotSet::Generate()
{
	MandelbrotSet::Result retval;
	unsigned int xPos = 0;
	unsigned int yPos = 0;

	retval.resize(m_height);

	for (yPos = 0; yPos < m_height; yPos++)
	{
		double pointImaginary = m_originImaginary + (static_cast<double>(yPos) * m_imaginaryRange / static_cast<double>(m_height));

		retval[yPos].resize(m_width);

		for (xPos = 0; xPos < m_width; xPos++)
		{
			double pointReal = m_originReal + (static_cast<double>(xPos) * m_realRange / static_cast<double>(m_width));
			
			unsigned int iters = IteratePoint(pointReal, pointImaginary);
			
			if (iters > m_maxIterations)
			{
				iters = m_maxIterations;
			}
			
			retval[yPos][xPos] = iters;
			
			if (iters < m_fewestIterations)
			{
				m_fewestIterations = iters;
			}
			
			if (iters > m_mostIterations)
			{
				m_mostIterations = iters;
			}
		}
	}
	
	return retval;
}

double MandelbrotSet::ComplexAbsSquared(double real, double imaginary)
{
	double retval = 0.0;
	
	retval = (real * real) + (imaginary * imaginary);
	return retval;
}

unsigned int MandelbrotSet::IteratePoint(double real, double imaginary)
{
	double zReal = real;
	double zImaginary = imaginary;
	double newReal = 0.0;
	double newImaginary = 0.0;
	
	unsigned int iters = 0;
	bool escaped = false;
	
	while (iters < m_maxIterations && !escaped)
	{
		// Check first so that we don't need to iterate at all if the point we're given is already outside the boundary.
		if (ComplexAbsSquared(zReal, zImaginary) > 4.0)
		{
			escaped = true;
		}
		else
		{
			// Both change and both depend on their initial values, so we have to do the calculation into temporaries.
			newReal = (zReal * zReal) - (zImaginary * zImaginary);
			newImaginary = 2 * zReal * zImaginary;
			
			// The iterator is z(n+1) = z(n)^2 + c, so we must add the real and imaginary parts of the constant each time.
			zReal = newReal + real;
			zImaginary = newImaginary + imaginary;

			iters++;
		}
	}
	
	return iters;
}
