#include <stdio.h>

float complexAbsSquared(float real, float imaginary)
{
	float retval = 0.0f;

	retval = (real * real) + (imaginary * imaginary);
	return retval;
}

int mandelbrotPoint(float real, float imaginary, int maxIterations)
{
	float zReal = real;
	float zImaginary = imaginary;
	float newReal = 0.0f;
	float newImaginary = 0.0f;

	int iters = 0;
	bool escaped = false;

	while (iters < maxIterations && !escaped)
	{
		// Check first so that we don't need to iterate at all if the
		// point we're given is already outside the boundary.
		if (complexAbsSquared(zReal, zImaginary) > 4.0f)
		{
			escaped = true;
		}
		else
		{
			// Both change and both depend on their initial values, so
			// we have to do the calculation into temporaries.
			newReal = (zReal * zReal) - (zImaginary * zImaginary);
			newImaginary = 2 * zReal * zImaginary;

			// The iterator is z(n+1) = z(n)^2 + c, so we must add
			// the real and imaginary parts of the constant each time.
			zReal = newReal + real;
			zImaginary = newImaginary + imaginary;
		}
		
		if (!escaped)
		{
			iters++;
		}
	}

	return iters;
}

void mandelbrotPlot(float xBegin, float yBegin, float width, float height,
	unsigned char maxIterations, int area, unsigned char* output)
{
	int xPos = 0;
	int yPos = 0;

	if (!output || width <= 0.0f || height <= 0.0f || maxIterations == 0 || area == 0)
	{
		printf("Bad value: %p %2.3f, %2.3f, %d, %d\n", output, width, height, maxIterations, area);
		return;
	}

	float range = static_cast<float>(area);
	int pos = 0;
	float real = 0.0f;
	float imaginary = 0.0f;

	for (yPos = 0; yPos < area; yPos++)
	{
		imaginary = (static_cast<float>(yPos) * height) / range + yBegin;

		for (xPos = 0; xPos < area; xPos++)
		{
			int iters = 0;

			real = (static_cast<float>(xPos) * width) / range + xBegin;

			if (yPos == 0)
			{
				if (xPos != 0)
				{
					printf(", ");
				}

				printf("%2.3f", real);
			}

			iters = mandelbrotPoint(real, imaginary, maxIterations);
			
			if (iters > maxIterations)
			{
				output[pos] = maxIterations;
			}
			else if (iters < 0)
			{
				output[pos] = 0;
			}
			else
			{
				output[pos] = iters;
			}

			pos++;
		}

		// For row 0 we just printed all the X co-ords.
		if (yPos == 0)
		{
			printf("\n");
		}

		printf("%2.3f\n", imaginary);
	}
}

int main(int argc, char* argv[])
{
	int size = 0;
	int count = 0;
	int x = 0;
	int y = 0;

	if (argc > 1)
	{
		sscanf(argv[1], "%d", &size);
		printf("Turned '%s' into %d\n", argv[1], size);
	}

	// Default unless a valid size was explicitly provided.
	if (size == 0)
	{
		size = 64;
	}

	// Allow the whole thing to be treated as a string if necessary.	
	unsigned char result[size * size + 1];
	result[size * size] = '\0';

	// 223 lets us run from ascii 32 to 255 inclusive, so that spaces
	// show the set.
	mandelbrotPlot(-2.5f, -2.5f, 5.0f, 5.0f, 223, size, result);

	// Convert from pure iterations to the ascii output set.
	for (count = 0; count < size * size; count++)
	{
		result[count] += 32;
	}

	for (y = 0; y < size; y++)
	{
		for (x = 0; x < size; x++)
		{
			putchar(result[x + y * size]);
		}

		putchar('\n');
	}

	return 0;
}
