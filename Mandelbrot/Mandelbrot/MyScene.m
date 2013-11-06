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

@implementation MyScene

SKSpriteNode* createMandelSprite(int setWidth, int setHeight)
{
	SKSpriteNode* retval = 0;

	double centerX = 0.0;
	double centerY = 0.0;
	double range = 4.0;
	double scaleX = 1.0;
	double scaleY = 1.0;
	double beginX = 0.0;
	double beginY = 0.0;
	double endX = 0.0;
	double endY = 0.0;

	// The area of the set we generate must have the same aspect ratio and the output
	// image will have.
	if (setWidth > setHeight)
	{
		scaleY = static_cast<double>(setHeight) / static_cast<double>(setWidth);
	}
	else
	{
		scaleX = static_cast<double>(setWidth) / static_cast<double>(setHeight);
	}

	beginX = centerX - (range * scaleX / 2.0);
	endX = beginX + range * scaleX;
	beginY = centerY - (range * scaleY / 2.0);
	endY = beginY + range * scaleY;

	MandelbrotSet set(beginX, beginY, endX, endY, setWidth, setHeight, 255);
	MandelbrotSet::Result output = set.Generate();
	
	NSBitmapImageRep* mandelImage = [ [NSBitmapImageRep alloc] initWithBitmapDataPlanes: nil
																			 pixelsWide: setWidth
																			 pixelsHigh: setHeight
																		  bitsPerSample: 8
																		samplesPerPixel: 4
																			   hasAlpha: YES
																			   isPlanar: NO
																		 colorSpaceName: NSCalibratedRGBColorSpace
																			bytesPerRow: 0
																		   bitsPerPixel: 32 ];
	
	for (int y = 0; y < setHeight; y++)
	{
		for (int x = 0; x < setWidth; x++)
		{
			unsigned int val = output[y][x];
			CGFloat red;
			CGFloat green;
			CGFloat blue;
			
			// Make the set itself black. The rest goes from dim to bright so there's contrast
			// at the set's borders.
			if (val == 255)
			{
				red = 0.0f;
				green = 0.0f;
				blue = 0.0f;
			}
			else
			{
				// Opaque going from blue to cyan.
				red = 0.0f;
				green = ((CGFloat)val) / 254.0f;
				blue = 1.0f;
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

		int setWidth = CGRectGetMaxX(self.frame);
		int setHeight = CGRectGetMaxY(self.frame);
		
		SKSpriteNode* mandelSprite = createMandelSprite(setWidth, setHeight);
		mandelSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

		[self addChild:mandelSprite];

		self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha: 1.0];
	}
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
     /* Called when a mouse click occurs */
    
    CGPoint location = [theEvent locationInNode:self];

    //
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
