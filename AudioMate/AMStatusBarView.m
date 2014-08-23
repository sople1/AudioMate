//
//  AudioDeviceStatusBarView.m
//  AudioMate
//
//  Created by Ruben Nine on 27/11/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//

#import "AMStatusBarView.h"
#import <AMCoreAudio/AMCoreAudioDevice+Formatters.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>
#import "AMPreferences.h"
#import <AMCoreAudio/AMCoreAudio.h>

@interface AMStatusBarView ();

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *alternateImage;
@property (nonatomic, retain) NSImage *volumeImage;
@property (nonatomic, retain) NSImage *scaledAndTintedVolumeImage;
@property (nonatomic, strong) NSImage *appIconImage;

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NSString *topLine;
@property (nonatomic, retain) NSString *bottomLine;
@property (nonatomic, assign) BOOL canDisplayVolume;
@property (nonatomic, assign) AMDeviceInformationToShow displayMode;

@property (nonatomic, retain) NSMutableParagraphStyle *paragraphStyle;
@property (nonatomic, retain) NSDictionary *textFontAttributes;
@property (nonatomic, retain) NSDictionary *highlightedTextFontAttributes;
@property (nonatomic, retain) NSDictionary *largeTextFontAttributes;
@property (nonatomic, retain) NSDictionary *largeHighlightedTextFontAttributes;
@property (nonatomic, retain) NSShadow *textShadow;
@property (nonatomic, retain) NSAppearance *originalAppearance;

@end

@implementation AMStatusBarView

+ (instancetype)sharedInstance
{
    static AMStatusBarView *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSStatusItem *statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];

        sharedInstance = [[AMStatusBarView alloc] initWithStatusItem:statusItem];
    });

    return sharedInstance;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    self = [self initWithFrame:self.calculatedStatusBarRect];

    if (self)
    {
        // Initialization code here.
        self.statusItem = statusItem;
        self.statusItem.view = self;

        _isHighlighted = NO;
        _topLine = @"";
        _bottomLine = @"";

        // On OS X Yosemite (10.10) user may have vibrant dark theme enabled,
        // in that case, we want to force our UI to use the light theme.
        
        if ([self.originalAppearance.name isEqualTo:NSAppearanceNameVibrantDark])
        {
            self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controlTintChanged:)
                                                     name:NSControlTintDidChangeNotification
                                                   object:nil];
    }

    return self;
}

#pragma mark - Accessors

- (NSImage *)appIconImage
{
    if (!_appIconImage)
    {
        _appIconImage = [[NSImage imageNamed:@"AppIcon"] copy];
        _appIconImage.size = NSMakeSize(19, 19);
    }

    return _appIconImage;
}

- (NSImage *)volumeImage
{
    if (!_volumeImage)
    {
        _volumeImage = [NSImage imageNamed:@"Volume-control"];
    }

    return _volumeImage;
}

- (void)setAudioDevice:(AMCoreAudioDevice *)audioDevice
{
    if (audioDevice != _audioDevice)
    {
        _audioDevice = audioDevice;

        [self setup];
    }
}

-(NSAppearance *)originalAppearance
{
    if (!_originalAppearance)
    {
        _originalAppearance = self.effectiveAppearance;
    }
    
    return _originalAppearance;
}

- (NSMutableParagraphStyle *)paragraphStyle
{
    if (!_paragraphStyle)
    {
        _paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        _paragraphStyle.alignment = NSCenterTextAlignment;
    }

    return _paragraphStyle;
}

- (NSDictionary *)textFontAttributes
{
    if (!_textFontAttributes)
    {
        NSColor *fontColor;
        
        if ([self.originalAppearance.name isEqualTo:NSAppearanceNameVibrantDark])
        {
            fontColor = [NSColor whiteColor];
        }
        else
        {
            fontColor = [NSColor blackColor];
        }
        
        _textFontAttributes = @{
            NSFontAttributeName:[NSFont fontWithName:@"Helvetica-Bold"
                                                size:[NSFont systemFontSizeForControlSize:NSMiniControlSize]],
            NSForegroundColorAttributeName:fontColor,
            NSParagraphStyleAttributeName:self.paragraphStyle
        };

        DLog(@"textFontAttributes = %@", _textFontAttributes);
    }

    return _textFontAttributes;
}

- (NSDictionary *)highlightedTextFontAttributes
{
    if (!_highlightedTextFontAttributes)
    {
        NSColor *fontColor = [NSColor whiteColor];

        _highlightedTextFontAttributes = @{
            NSFontAttributeName:[NSFont fontWithName:@"Helvetica-Bold"
                                                size:[NSFont systemFontSizeForControlSize:NSMiniControlSize]],
            NSForegroundColorAttributeName:fontColor,
            NSParagraphStyleAttributeName:self.paragraphStyle
        };
    }

    return _highlightedTextFontAttributes;
}

- (NSDictionary *)largeTextFontAttributes
{
    if (!_largeTextFontAttributes)
    {
        NSColor *fontColor;
        
        if ([self.originalAppearance.name isEqualTo:NSAppearanceNameVibrantDark])
        {
            fontColor = [NSColor whiteColor];
        }
        else
        {
            fontColor = [NSColor blackColor];
        }
        
        _largeTextFontAttributes = @{
            NSFontAttributeName:[NSFont fontWithName:@"Helvetica-Bold"
                                                size:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
            NSForegroundColorAttributeName:fontColor,
            NSParagraphStyleAttributeName:self.paragraphStyle
        };
    }

    return _largeTextFontAttributes;
}

- (NSDictionary *)largeHighlightedTextFontAttributes
{
    if (!_largeHighlightedTextFontAttributes)
    {
        NSColor *fontColor = [NSColor whiteColor];
        
        _largeHighlightedTextFontAttributes = @{
            NSFontAttributeName:[NSFont fontWithName:@"Helvetica-Bold"
                                                size:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
            NSForegroundColorAttributeName:fontColor,
            NSParagraphStyleAttributeName:self.paragraphStyle
        };
    }

    return _largeHighlightedTextFontAttributes;
}

- (NSShadow *)textShadow
{
    if (!_textShadow)
    {
        NSColor *shadowColor;
        
        if ([self.originalAppearance.name isEqualTo:NSAppearanceNameVibrantDark])
        {
            shadowColor = [NSColor blackColor];
        }
        else
        {
            shadowColor = [NSColor whiteColor];
        }

        _textShadow = [NSShadow new];
        _textShadow.shadowColor = [shadowColor colorWithAlphaComponent:0.5];
        _textShadow.shadowOffset = NSMakeSize(0.1, -1.1);
        _textShadow.shadowBlurRadius = 0;
    }

    return _textShadow;
}

- (NSImage *)scaledAndTintedVolumeImage
{
    if (!_scaledAndTintedVolumeImage)
    {
        NSColor *color1;
        NSColor *color2;
        NSGradient *gradient;
        NSBezierPath *rectanglePath;
        NSRect imageRect;

        _scaledAndTintedVolumeImage = [self.volumeImage copy];
        _scaledAndTintedVolumeImage.size = NSMakeSize(38, 8);

        imageRect = NSMakeRect(0,
                               0,
                               _scaledAndTintedVolumeImage.size.width,
                               _scaledAndTintedVolumeImage.size.height);

        // Tint the image to an specific color
        // The color is derived from the system's control appareance: blue or graphite
        [_scaledAndTintedVolumeImage lockFocus];

        AMStatusBarAppearance statusBarAppearance = [AMPreferences sharedPreferences].general.statusBarAppearance;

        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceAtop];

        if (statusBarAppearance == AMSystemStatusBarAppearance)
        {
            if ([NSColor currentControlTint] == NSBlueControlTint)
            {
                statusBarAppearance = AMBlueStatusBarAppearance;
            }
            else if ([NSColor currentControlTint] == NSGraphiteControlTint)
            {
                statusBarAppearance = AMGraphiteStatusBarAppearance;
            }
        }

        if (statusBarAppearance == AMBlueStatusBarAppearance)
        {
            color1 = [NSColor colorWithCalibratedHue:0.625
                                          saturation:0.98
                                          brightness:0.95
                                               alpha:1];

            color2 = [NSColor colorWithCalibratedHue:0.625
                                          saturation:0.71
                                          brightness:0.41
                                               alpha:1];
        }
        else
        {
            color1 = [NSColor colorWithCalibratedHue:0.625
                                          saturation:0.2
                                          brightness:0.45
                                               alpha:1];

            color2 = [NSColor colorWithCalibratedHue:0.625
                                          saturation:0.2
                                          brightness:0.2
                                               alpha:1];
        }

        gradient = [[NSGradient alloc] initWithStartingColor:color1
                                                 endingColor:color2];

        rectanglePath = [NSBezierPath bezierPathWithRect:imageRect];

        [gradient drawInBezierPath:rectanglePath
                             angle:90];

        [_scaledAndTintedVolumeImage unlockFocus];
    }

    return _scaledAndTintedVolumeImage;
}

- (void)setIsHighlighted:(BOOL)isHighlighted
{
    _isHighlighted = isHighlighted;

    [self setNeedsDisplay:YES];
}

- (void)setTopLine:(NSString *)topLine
{
    _topLine = topLine;

    [self setNeedsDisplay:YES];
}

- (void)setBottomLine:(NSString *)bottomLine
{
    _bottomLine = bottomLine;

    [self setNeedsDisplay:YES];
}

- (NSImage *)icon
{
    NSImage *theIcon;

    theIcon = (self.isHighlighted && self.alternateImage) ? self.alternateImage : self.image;

    return theIcon;
}

#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [self setup];

    NSDictionary *attributes;

    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect
                                     withHighlight:self.isHighlighted];

    if (self.displayMode == AMSampleRateOnly)
    {
        attributes = self.isHighlighted ? self.largeHighlightedTextFontAttributes : self.largeTextFontAttributes;
    }
    else
    {
        attributes = self.isHighlighted ? self.highlightedTextFontAttributes : self.textFontAttributes;
    }

    self.frame = self.calculatedStatusBarRect;

    [NSGraphicsContext saveGraphicsState];

    if (self.icon)
    {
        NSRect bounds;
        NSSize iconSize;
        CGFloat iconX;
        CGFloat iconY;
        NSPoint iconPoint;

        bounds = self.bounds;
        iconSize = self.icon.size;
        iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
        iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
        iconPoint = NSMakePoint(iconX, iconY);

        [self.icon drawAtPoint:iconPoint
                      fromRect:NSZeroRect
                     operation:NSCompositeSourceOver
                      fraction:1.0];
    }
    else
    {
        if (!self.isHighlighted)
        {
            [self.textShadow set];
        }

        if (self.displayMode == AMSampleRateOnly)
        {
            [self.topLine drawInRect:self.fullFrameRect
                      withAttributes:attributes];
        }
        else
        {
            [self.topLine drawInRect:self.topHalfRect
                      withAttributes:attributes];

            if (self.displayMode == AMSampleRateAndClockSource)
            {
                [self.bottomLine drawInRect:self.bottomHalfRect
                             withAttributes:attributes];
            }
            else if (self.canDisplayVolume)
            {
                switch (self.displayMode)
                {
                    case AMSampleRateAndMasterOutVolume:
                        [self.bottomLine drawInRect:self.bottomHalfRect
                                     withAttributes:attributes];

                        break;

                    case AMSampleRateAndMasterOutGraphicVolume:

                        if ([self.bottomLine isEqualToString:@"Muted"])
                        {
                            [self.bottomLine drawInRect:self.bottomHalfRect
                                         withAttributes:attributes];
                        }
                        else
                        {
                            [self drawVolumeGraphic];
                        }

                        break;

                    case AMSampleRateAndMasterOutVolumePercent:

                        if (![self.bottomLine isEqualToString:@"Muted"])
                        {
                            self.bottomLine = [NSString stringWithFormat:@"%ld%%",
                                               (NSInteger)roundf([self scalarVolume] * 100)];
                        }

                        [self.bottomLine drawInRect:self.bottomHalfRect
                                     withAttributes:attributes];
                        break;

                    default:
                        break;
                }
            }
            else
            {
                [@"N/A" drawInRect : self.bottomHalfRect
                 withAttributes : attributes];
            }
        }
    }

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawVolumeGraphic
{
    DLog(@"drawing graphic volume");
    
    NSSize imageSize;
    NSRect bounds;
    CGFloat imageX;
    CGFloat imageY;
    NSPoint imagePoint;

    imageSize = self.scaledAndTintedVolumeImage.size;

    bounds = self.bounds;
    imageX = roundf((NSWidth(bounds) - imageSize.width) / 2);
    imageY = 3;
    imagePoint = NSMakePoint(imageX, imageY);

    NSRect volumeClippingRect = NSMakeRect(0,
                                           0,
                                           1 + [self scalarVolume] * imageSize.width,
                                           imageSize.height);

    [self.scaledAndTintedVolumeImage drawAtPoint:imagePoint
                                        fromRect:NSZeroRect
                                       operation:(self.isHighlighted ? NSCompositePlusLighter : NSCompositeSourceOut)
                                        fraction:0.3];

    [self.scaledAndTintedVolumeImage drawAtPoint:imagePoint
                                        fromRect:volumeClippingRect
                                       operation:(self.isHighlighted ? NSCompositePlusLighter : NSCompositeSourceOver)
                                        fraction:1.0];
}

#pragma mark Misc events

- (void)mouseDown:(NSEvent *)event
{
    self.isHighlighted = !self.isHighlighted;

    // Send action to target

    [NSApp sendAction:self.action
                   to:self.target
                 from:self];
}

- (void)controlTintChanged:(id)sender
{
    _scaledAndTintedVolumeImage = nil;

    [self setNeedsDisplay:YES];
}

#pragma mark Helpers

- (NSRect)calculatedStatusBarRect
{
    NSImage *icon;
    NSRect rect;
    CGFloat width;

    icon = self.icon;

    if (icon)
    {
        width = icon.size.width + 8;
    }
    else if (self.displayMode == AMSampleRateOnly)
    {
        width = 80.0;
    }
    else
    {
        width = 64.0;
    }

    rect = NSMakeRect(0.0,
                      0.0,
                      width,
                      [NSStatusBar systemStatusBar].thickness);

    return rect;
}

- (NSRect)fullFrameRect
{
    return NSMakeRect(0.0,
                      0.0,
                      NSWidth(self.frame),
                      NSHeight(self.frame) - 2);
}

- (NSRect)bottomHalfRect
{
    return NSMakeRect(0.0,
                      1.0,
                      NSWidth(self.frame),
                      NSHeight(self.frame) * 0.5);
}

- (NSRect)topHalfRect
{
    return NSMakeRect(0.0,
                      (NSHeight(self.frame) * 0.5) - 1,
                      NSWidth(self.frame),
                      NSHeight(self.frame) * 0.5);
}

- (void)setup
{
    AMCoreAudioDirection direction = self.audioDevice.preferredDirectionForMasterVolume;

    self.displayMode = [AMPreferences sharedPreferences].device.deviceInformationToShow;
    self.canDisplayVolume = [self.audioDevice canSetMasterVolumeForDirection:direction];

    if (self.audioDevice.actualSampleRate != 0.0)
    {
        self.image = nil;
        self.topLine = [self.audioDevice actualSampleRateFormattedWithShortFormat:YES];
    }
    else
    {
        self.image = self.appIconImage;
        self.topLine = NSLocalizedString(@"N/A", nil);
    }

    switch ([AMPreferences sharedPreferences].device.deviceInformationToShow)
    {
        case AMSampleRateAndMasterOutVolume:
        case AMSampleRateAndMasterOutVolumePercent:
        case AMSampleRateAndMasterOutGraphicVolume:

            if (self.canDisplayVolume)
            {
                if ([self.audioDevice isMasterVolumeMutedForDirection:direction])
                {
                    self.bottomLine = NSLocalizedString(@"Muted", nil);
                }
                else
                {
                    self.bottomLine = [AMCoreAudioDevice formattedVolumeInDecibels:[self.audioDevice masterVolumeInDecibelsForDirection:direction]];
                }
            }
            else
            {
                self.bottomLine = NSLocalizedString(@"N/A", nil);
            }

            break;

        case AMSampleRateAndClockSource:
        {
            NSString *clockSourceName;

            clockSourceName = [self.audioDevice clockSourceForChannel:kAudioObjectPropertyElementMaster
                                                         andDirection:kAMCoreAudioDevicePlaybackDirection];
            self.bottomLine = clockSourceName;

            break;
        }

        case AMSampleRateOnly:
            self.bottomLine = nil;

            break;

        default:
            break;
    }
}

- (Float32)scalarVolume
{
    AMCoreAudioDirection direction = self.audioDevice.preferredDirectionForMasterVolume;

    return [self.audioDevice masterVolumeForDirection:direction];
}

@end
