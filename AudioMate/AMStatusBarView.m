//
//  AudioDeviceStatusBarView.m
//  AudioMate
//
//  Created by Ruben Nine on 27/11/13.
//  Copyright (c) 2013 Ruben Nine. All rights reserved.
//
// TODO: Completely refactor this POS.

#import "AMStatusBarView.h"
#import <AMCoreAudio/AMCoreAudioDevice+Formatters.h>
#import <AMCoreAudio/AMCoreAudioDevice+PreferredDirections.h>
#import "AMPreferences.h"
#import <AMCoreAudio/AMCoreAudio.h>
#import "NSString+Calculations.h"

@interface AMStatusBarView ()

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
@property (nonatomic, assign) BOOL useDarkTheme;

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
        self.useDarkTheme = NO;

        _isHighlighted = NO;
        _topLine = @"";
        _bottomLine = @"";

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 101000

        if (lround(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
        {
            // On OS X Yosemite (10.10) user may have vibrant dark theme enabled,
            // in that case, we want to force our UI to use the light theme.

            self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        }

#endif

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
        _appIconImage = [[NSImage imageNamed:@"Speaker"] copy];

        _appIconImage.size = NSMakeSize(16, 12);
    }

    return _appIconImage;
}

- (void)setImage:(NSImage *)image
{
    _image = image;

    if (!_image)
    {
        _alternateImage = nil;

        return;
    }

    _alternateImage = [_image copy];

    [_alternateImage lockFocus];
    {
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceAtop];

        NSRect rect = NSMakeRect(0, 0, _appIconImage.size.width, _appIconImage.size.height);

        NSBezierPath *rectanglePath = [NSBezierPath bezierPathWithRect:rect];

        [[NSColor whiteColor] setFill];
        [rectanglePath fill];
    }
    [_alternateImage unlockFocus];
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

        if (self.useDarkTheme)
        {
            fontColor = [NSColor whiteColor];
        }
        else
        {
            fontColor = [NSColor blackColor];
        }

        _textFontAttributes = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]],
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: self.paragraphStyle
        };
    }

    return _textFontAttributes;
}

- (NSDictionary *)highlightedTextFontAttributes
{
    if (!_highlightedTextFontAttributes)
    {
        NSColor *fontColor = [NSColor whiteColor];

        _highlightedTextFontAttributes = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]],
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: self.paragraphStyle
        };
    }

    return _highlightedTextFontAttributes;
}

- (NSDictionary *)largeTextFontAttributes
{
    if (!_largeTextFontAttributes)
    {
        NSColor *fontColor;

        if (self.useDarkTheme)
        {
            fontColor = [NSColor whiteColor];
        }
        else
        {
            fontColor = [NSColor blackColor];
        }

        _largeTextFontAttributes = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: self.paragraphStyle
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
            NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: self.paragraphStyle
        };
    }

    return _largeHighlightedTextFontAttributes;
}

- (NSShadow *)textShadow
{
    if (!_textShadow)
    {
        NSColor *shadowColor;

        if (self.useDarkTheme)
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
    // Return a dark or light version of the icon

    return (self.useDarkTheme || self.isHighlighted) && self.alternateImage ? self.alternateImage : self.image;
}

#pragma mark Drawing

- (void)viewDidChangeBackingProperties
{
    DLog(@"it happened");

    [super viewDidChangeBackingProperties];
}

- (void)drawRect:(NSRect)dirtyRect
{
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 101000

    if (lround(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
    {
        BOOL shouldUseDarkTheme = [self.superview.effectiveAppearance.name isEqualTo:NSAppearanceNameVibrantDark];

        if (shouldUseDarkTheme != self.useDarkTheme)
        {
            self.useDarkTheme = shouldUseDarkTheme;
            self.textShadow = nil;
            self.largeTextFontAttributes = nil;
            self.textFontAttributes = nil;
        }
    }

#endif

    if (NSEqualRects(dirtyRect, self.bounds))
    {
        [self setup];
    }

    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect
                                     withHighlight:self.isHighlighted];

    NSDictionary *attributes;

    if (self.displayMode == AMSampleRateOnly)
    {
        attributes = self.isHighlighted ? self.largeHighlightedTextFontAttributes : self.largeTextFontAttributes;
    }
    else
    {
        attributes = self.isHighlighted ? self.highlightedTextFontAttributes : self.textFontAttributes;
    }

    [NSGraphicsContext saveGraphicsState];

    if (self.icon)
    {
        NSSize iconSize;
        CGFloat iconX;
        CGFloat iconY;
        NSPoint iconPoint;

        iconSize = self.icon.size;
        iconX = roundf((NSWidth(self.frame) - iconSize.width) / 2);
        iconY = roundf((NSHeight(self.frame) - iconSize.height) / 2);
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
            NSAttributedString *asp = [[NSAttributedString alloc] initWithString:self.topLine attributes:attributes];

            CGRect stringRect = [self.topLine dimensionsForAttributedString:asp];
            CGFloat dY = round(fabs(self.frame.size.height - stringRect.size.height) / 2) - 1;

            [self.topLine drawInRect:NSInsetRect(self.frame, 0, dY)
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
                [@"N/A" drawInRect:self.bottomHalfRect
                    withAttributes:attributes];
            }
        }
    }

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawVolumeGraphic
{
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
                                       operation:NSCompositeSourceOver
                                        fraction:self.isHighlighted ? 1.0 : 0.2];

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
    NSRect rect;
    CGFloat width;

    if (!self.audioDevice)
    {
        width = self.appIconImage.size.width + 8;
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

    self.frame = self.calculatedStatusBarRect;
}

- (Float32)scalarVolume
{
    AMCoreAudioDirection direction = self.audioDevice.preferredDirectionForMasterVolume;

    return [self.audioDevice masterVolumeForDirection:direction];
}

@end
