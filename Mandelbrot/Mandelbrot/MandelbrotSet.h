//
//  MandelbrotSet.h
//  Mandelbrot
//
//  Created by Graham West on 11/4/13.
//  Copyright (c) 2013 Graham West. All rights reserved.
//

#ifndef __Mandelbrot__MandelbrotSet__
#define __Mandelbrot__MandelbrotSet__

#include <vector>

class MandelbrotSet
{
public:
	typedef std::vector< std::vector<unsigned int> > Result;

	// Everything we need in order to generate results; what region  to cover, the resolution for our output
	// and how many iterations to try before deciding the point is within the set (ie. bounded).
    explicit MandelbrotSet(double originReal, double originImaginary, double endReal, double endImaginary,
        unsigned int width, unsigned int height, unsigned int maxIterations);

    ~MandelbrotSet();
    MandelbrotSet(const MandelbrotSet& src);
    MandelbrotSet& operator=(const MandelbrotSet& src);

    Result Generate();

	inline unsigned int fewestIterations() { return m_fewestIterations; }
	inline unsigned int mostIterations() { return m_mostIterations; }

private:
    MandelbrotSet();

	// The absolute value of a+bi is sqrt(a*a + b*b) but we don't need the square root because this is only
	// for comparison.
	double ComplexAbsSquared(double real, double imaginary);
	unsigned int IteratePoint(double real, double imaginary);

    double m_originReal;
    double m_originImaginary;
    double m_realRange;
    double m_imaginaryRange;
    unsigned int m_width;
    unsigned int m_height;
    unsigned int m_maxIterations;
	unsigned int m_fewestIterations;
	unsigned int m_mostIterations;
};

#endif /* defined(__Mandelbrot__MandelbrotSet__) */
