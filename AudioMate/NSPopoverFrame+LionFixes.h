//
//  NSPopoverFrame+fixes.h
//  AudioMate
//
//  Created by Ruben Nine on 14/01/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import <AppKit/NSView.h>

@interface NSPopoverFrame : NSView

@property struct CGSize anchorSize;

@end

@interface NSPopoverFrame (LionFixes)

- (struct CGRect)titlebarRect;

@end
