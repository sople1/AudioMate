//
//  NSString+Calculations.m
//  AudioMate
//
//  Created by Ruben on 5/28/15.
//  Copyright (c) 2015 Ruben Nine. All rights reserved.
//

#import "NSString+Calculations.h"

@implementation NSString (Calculations)

/*!
 Calculates the rect needed to render this string using a given NSAttributedString.
 */
- (CGRect)dimensionsForAttributedString:(NSAttributedString *)asp
{
    CGFloat ascent = 0;
    CGFloat descent = 0;

    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)asp);
    double width = CTLineGetTypographicBounds(line, &ascent, &descent, nil);

    width = ceil(width); // Force width to integral.

    if ((NSInteger)width % 2 != 0)
    {
        width += 1; // Force width to even.
    }

    return CGRectMake(0, -descent, width, ceil(ascent + descent));
}

/*!
 Calculates the rect needed to render this string using font and size.
 */
- (CGRect)dimensionsUsingFont:(NSString *)fontName atSize:(CGFloat)fontSize
{
    NSFont *font = [NSFont fontWithName:fontName size:fontSize];

    if (font)
    {
        NSDictionary *attribs = @{ NSFontAttributeName: font };
        NSAttributedString *asp = [[NSAttributedString alloc] initWithString:self attributes:attribs];

        return [self dimensionsForAttributedString:asp];
    }
    else
    {
        DLog("Unable to create font named %@ with size %@.", fontName, @(fontSize));
    }

    return CGRectZero;
}

@end
