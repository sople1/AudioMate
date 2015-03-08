//
//  AppDelegate.m
//  AudioMateLauncher
//
//  Created by Ruben Nine on 12/24/12.
//  Copyright (c) 2012 Ruben Nine. All rights reserved.
//

#import "AMAppDelegate.h"

@implementation AMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check if main app is already running; if yes, do nothing and terminate helper app

    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];

    for (NSRunningApplication *app in running)
    {
        if ([[app bundleIdentifier] isEqualToString:@"io.9labs.AudioMate"] ||
            [[app bundleIdentifier] isEqualToString:@"com.troikalabs.AudioMate"])
        {
            alreadyRunning = YES;
        }
    }

    if (!alreadyRunning)
    {
        NSString *path = [NSBundle mainBundle].bundlePath;
        NSMutableArray *pathComponents = [path.pathComponents mutableCopy];

        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:@"AudioMate"];

        NSString *newPath = [NSString pathWithComponents:pathComponents];

        [[NSWorkspace sharedWorkspace] launchApplication:newPath];
    }

    [NSApp terminate:nil];
}

@end
