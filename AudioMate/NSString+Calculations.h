//
//  NSString+Calculations.h
//  AudioMate
//
//  Created by Ruben on 5/28/15.
//  Copyright (c) 2015 Ruben Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Calculations)

- (CGRect)dimensionsForAttributedString:(NSAttributedString *)asp;
- (CGRect)dimensionsUsingFont:(NSString *)fontName atSize:(CGFloat)fontSize;

@end
