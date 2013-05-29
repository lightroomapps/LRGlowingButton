//
//  LRGlowingButton.m
//
//  Created by Nikita Lutsenko on 3/13/13.
//  Copyright (c) 2013 lightroomapps. All rights reserved.
//

#import "LRGlowingButton.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation LRGlowingButton

#pragma mark -
#pragma mark UIButton

-(void)setHighlighted:(BOOL)highlighted
{
    if (self.highlighted != highlighted)
    {
        [super setHighlighted:highlighted];
        
        if (self.glowsWhenHighlighted && highlighted)
            [self __startGlowing];
        else
            [self __stopGlowing];
    }
}

#pragma mark -
#pragma mark Custom Setters

-(void)setGlowsWhenHighlighted:(BOOL)glowsWhenHighlighted
{
    if (self.glowsWhenHighlighted != glowsWhenHighlighted)
    {
        _glowsWhenHighlighted = glowsWhenHighlighted;
        
        self.adjustsImageWhenHighlighted = !self.glowsWhenHighlighted;
    }
}

#pragma mark -
#pragma mark Glow

-(void)__startGlowing
{
    if ([self __glowView])
        return;
    
    CGFloat glowSpread = 60.0f;
    
    UIImage *image = nil;
    CGSize imageSize = CGSizeMake(self.bounds.size.width + glowSpread, self.bounds.size.height + glowSpread);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);
        
        CGContextSaveGState(context);
        
        CGGradientRef gradient = [[self class] __newGlowGradientWithColor:self.highlightedGlowColor];
        
        CGPoint gradCenter = CGPointMake(floorf(imageSize.width / 2.0f), floorf(imageSize.height / 2.0f));
        CGFloat gradRadius = MAX(imageSize.width, imageSize.height) / 2.0f;
        
        CGContextDrawRadialGradient(context, gradient, gradCenter, 0.0f, gradCenter, gradRadius, kCGGradientDrawsBeforeStartLocation);
        
        CGGradientRelease(gradient), gradient = NULL;
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, glowSpread / 2.0f, glowSpread / 2.0f);
        
        [self.layer renderInContext:context];
        
        CGContextRestoreGState(context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    // Make the glowing view itself, and position it at the same
    // point as ourself. Overlay it over ourself.
    UIView *glowView = [[[UIImageView alloc] initWithImage:image] autorelease];
    glowView.center = self.center;
    [self.superview insertSubview:glowView aboveSubview:self];
    
    // We don't want to show the image, but rather a shadow created by
    // Core Animation. By setting the shadow to white and the shadow radius to
    // something large, we get a pleasing glow.
    glowView.alpha = 0.0f;
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^{
         glowView.layer.opacity = 1.0f;
     }
                     completion:nil];
    [self __setGlowView:glowView];
}

-(void)__stopGlowing
{
    UIView *glowView = [self __glowView];
    if (glowView)
    {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                         animations:
         ^{
             glowView.layer.opacity = 0.0f;
         }
                         completion:
         ^(BOOL finished)
         {
             [self __setGlowView:nil];
         }];
    }
}

-(UIView*)__glowView
{
    return objc_getAssociatedObject(self, @"LRGlowView");
}

-(void)__setGlowView:(UIView*)view
{
    if (view == nil)
        [[self __glowView] removeFromSuperview];
    objc_setAssociatedObject(self, @"LRGlowView", view, OBJC_ASSOCIATION_RETAIN);
}

+(CGGradientRef)__newGlowGradientWithColor:(UIColor*)color
{
    CGColorRef cgColor = [color CGColor];
    
    const CGFloat *sourceColorComponents = CGColorGetComponents(cgColor);
    
    CGFloat sourceRed;
    CGFloat sourceGreen;
    CGFloat sourceBlue;
    CGFloat sourceAlpha;
    if (CGColorGetNumberOfComponents(cgColor) == 2)
    {
        sourceRed = sourceColorComponents[0];
        sourceGreen = sourceColorComponents[0];
        sourceBlue = sourceColorComponents[0];
        sourceAlpha = sourceColorComponents[1];
    }
    else
    {
        sourceRed = sourceColorComponents[0];
        sourceGreen = sourceColorComponents[1];
        sourceBlue = sourceColorComponents[2];
        sourceAlpha = sourceColorComponents[3];
    }
    
    size_t locationsCount = 20;
    CGFloat step = 1.0f / locationsCount;
    
    CGFloat colorComponents[4 * locationsCount];
    CGFloat locations[locationsCount];
    
    NSUInteger componentsIndex = 0;
    for (NSUInteger index = 0; index < locationsCount; index++)
    {
        CGFloat point = index * step;
        locations[index] = point;
        
        CGFloat alpha = sourceAlpha * (1 - 0.5 * (1 - cos(point * M_PI)));
        
        colorComponents[componentsIndex] = sourceRed;
        colorComponents[componentsIndex + 1] = sourceGreen;
        colorComponents[componentsIndex + 2] = sourceBlue;
        colorComponents[componentsIndex + 3] = alpha;
        componentsIndex += 4;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, locationsCount);
    
    CGColorSpaceRelease(colorSpace), colorSpace = NULL;
    
    return gradient;
}

#pragma mark -
#pragma mark Dealloc

-(void)dealloc
{
    self.highlightedGlowColor = nil;
    [self __setGlowView:nil];
    
    [super dealloc];
}

@end
