//
//  MyScene.m
//  Mandelbrot
//
//  Created by Graham West on 11/4/13.
//  Copyright (c) 2013 Graham West. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MyScene.h"
#include "MandelbrotSet.h"

@interface MyScene ()
@property double centerX;
@property double centerY;
@property double range;
@property unsigned int iterations;
@property SKSpriteNode* mandelSprite;

-(SKSpriteNode*)createMandelbrotWidth:(int)width height:(int)height;
@end

double rangeToProportion(unsigned int min, unsigned int max, unsigned int val)
{
	double retval = 1.0;
	
	if (max > min)
	{
		double dMin = static_cast<double>(min);
		double dMax = static_cast<double>(max);
		double dVal = static_cast<double>(val);
		
		retval = (dVal - dMin) / (dMax - dMin);
	}
	
	return retval;
}

@implementation MyScene

-(SKSpriteNode*)createMandelbrotWidth:(int)width height:(int)height
{
	SKSpriteNode* retval = 0;

	double scaleX = 1.0;
	double scaleY = 1.0;
	double beginX = 0.0;
	double beginY = 0.0;
	double endX = 0.0;
	double endY = 0.0;

	// The area of the set we generate must have the same aspect ratio and the output
	// image will have.
	if (width > height)
	{
		scaleY = static_cast<double>(height) / static_cast<double>(width);
	}
	else
	{
		scaleX = static_cast<double>(width) / static_cast<double>(height);
	}

	beginX = _centerX - (_range * scaleX / 2.0);
	endX = beginX + _range * scaleX;
	beginY = _centerY - (_range * scaleY / 2.0);
	endY = beginY + _range * scaleY;

	MandelbrotSet set(beginX, beginY, endX, endY, width, height, _iterations);
	MandelbrotSet::Result output = set.Generate();
	
	NSBitmapImageRep* mandelImage = [ [NSBitmapImageRep alloc] initWithBitmapDataPlanes: nil
																			 pixelsWide: width
																			 pixelsHigh: height
																		  bitsPerSample: 8
																		samplesPerPixel: 4
																			   hasAlpha: YES
																			   isPlanar: NO
																		 colorSpaceName: NSCalibratedRGBColorSpace
																			bytesPerRow: 0
																		   bitsPerPixel: 32 ];

	int x = 0;
	int y = 0;
	unsigned int least = _iterations;
	unsigned int most = 0;

	// We want to use the whole colour gradiant on each image, which means we need to know the
	// most and least iterations that will be coloured. The set itself will be black and so
	// shouldn't affect our colour range.
	for (y = 0; y < height; y++)
	{
		for (x = 0; x < height; x++)
		{
			unsigned int val = output[y][x];

			if (val < _iterations)
			{
				if (val < least)
				{
					least = val;
				}
				
				if (val > most)
				{
					most = val;
				}
			}
		}
	}

	for (y = 0; y < height; y++)
	{
		for (x = 0; x < width; x++)
		{
			unsigned int val = output[y][x];
			CGFloat red = 0.0f;
			CGFloat green = 0.0f;
			CGFloat blue = 0.0f;

			// Place in the range is (val - least + 1) / (most - least + 1)
			// Make the set itself black. The rest goes from dim to bright so there's contrast
			// at the set's borders.
			if (val == _iterations)
			{
				red = 0.0f;
				green = 0.0f;
				blue = 0.0f;
			}
			else
			{
				// Opaque going from dark blue to cyan.
				red = 0.0f;
				green = rangeToProportion(least, most, val);
				blue = green * 0.66f + 0.33f;
			}

			NSColor *color = [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: 1.0f];
			[mandelImage setColor: color atX: x y: y];
		}
	}
	
	CGImageRef mandelRef = [mandelImage CGImage];
	SKTexture* mandelTexture = [SKTexture textureWithCGImage: mandelRef];
	retval = [SKSpriteNode spriteNodeWithTexture: mandelTexture];
	
	return retval;
}

-(id)initWithSize:(CGSize)size {

    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

		int frameWidth = CGRectGetMaxX(self.frame);
		int frameHeight = CGRectGetMaxY(self.frame);

		_centerX = 0.0;
		_centerY = 0.0;
		_range = 3.5;
		_iterations = 500;

		_mandelSprite = [self createMandelbrotWidth: frameWidth height: frameHeight];
		_mandelSprite.position = CGPointMake(frameWidth / 2, frameHeight / 2);

		[self addChild:_mandelSprite];

		self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha: 1.0];
	}
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
     /* Called when a mouse click occurs */
    
	int frameWidth = CGRectGetMaxX(self.frame);
	int frameHeight = CGRectGetMaxY(self.frame);
	CGPoint location = [theEvent locationInNode: self];

	// Calculate where the click happened relative to the center of the frame. The location
	// uses the bottom-left as (0,0) so we must flip the Y fraction. To get from the
	// corner to the center we can just subtract 0.5.
	double offsetX = location.x / static_cast<double>(frameWidth);
	double offsetY = 1.0 - (location.y / static_cast<double>(frameHeight));

	offsetX -= 0.5;
	offsetY -= 0.5;
	
	_centerX = _centerX + offsetX * _range;
	_centerY = _centerY + offsetY * _range;
	_range = _range * 0.4;

	SKSpriteNode* newMandel = [self createMandelbrotWidth: frameWidth height:frameHeight];
	newMandel.position = CGPointMake(frameWidth / 2, frameHeight / 2);

	if (_mandelSprite)
	{
		[_mandelSprite removeFromParent];
	}
	
	[self addChild:newMandel];
	_mandelSprite = newMandel;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
