//
//  NSTimer+EOCBlocksSupport.m
//  AudioMaestro
//
//  Created by Ruben Nine on 23/02/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "NSTimer+EOCBlocksSupport.h"

@implementation NSTimer (EOCBlocksSupport)

+ (NSTimer*)eoc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void (^)())block
                                       repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(eoc_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)eoc_blockInvoke:(NSTimer*)timer
{
    void (^block)() = timer.userInfo;

    if (block)
    {
        block();
    }
}

@end
