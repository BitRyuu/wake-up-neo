//
//  Wake_up_NeoView.m
//  Wake up Neo
//
//  Created by sagar b on 13/03/26.
//

#import "Wake_up_NeoView.h"
#import <AppKit/AppKit.h>

@interface Wake_up_NeoView () {
    NSArray<NSString *> *_messages;
    NSInteger _currentMessageIndex;
    NSInteger _currentCharIndex;
    BOOL _isClearingPause;
    NSInteger _framePauseCounter;
}
@end

@implementation Wake_up_NeoView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        // ~30 fps
        [self setAnimationTimeInterval:1.0/30.0];

        _messages = @[ @"Wake up, Neo...",
                       @"The Matrix has you...",
                       @"Follow the white rabbit.",
                       @"Knock, knock, Neo." ];
        _currentMessageIndex = 0;
        _currentCharIndex = 0;
        _isClearingPause = NO;
        _framePauseCounter = 0;
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);

    if (_isClearingPause) {
        return;
    }

    NSColor *matrixGreen = [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0];

    CGFloat baseSize = MIN(NSWidth(self.bounds), NSHeight(self.bounds));
    CGFloat fontSize = MAX(14.0, baseSize * 0.06);

    NSFont *font = [NSFont monospacedSystemFontOfSize:fontSize weight:NSFontWeightRegular];
    NSDictionary *attrs = @{ NSForegroundColorAttributeName: matrixGreen,
                             NSFontAttributeName: font };

    NSString *fullLine = _messages[_currentMessageIndex];
    NSInteger safeLen = MAX(0, MIN(_currentCharIndex, (NSInteger)fullLine.length));
    NSString *toDraw = [fullLine substringToIndex:safeLen];

    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:toDraw attributes:attrs];
    NSSize textSize = [attrStr size];

    CGFloat x = (NSWidth(self.bounds) - textSize.width) / 2.0;
    CGFloat y = (NSHeight(self.bounds) - textSize.height) / 2.0;

    [attrStr drawAtPoint:NSMakePoint(x, y)];
}

- (void)animateOneFrame
{
    static const NSInteger framesPerChar = 2;
    static const NSInteger pauseAfterLineFrames = 45;
    static const NSInteger pauseClearedFrames = 15;

    if (_isClearingPause) {
        _framePauseCounter++;
        if (_framePauseCounter >= pauseClearedFrames) {
            _isClearingPause = NO;
            _framePauseCounter = 0;
            _currentMessageIndex = (_currentMessageIndex + 1) % _messages.count;
            _currentCharIndex = 0;
        }
        [self setNeedsDisplay:YES];
        return;
    }

    NSString *current = _messages[_currentMessageIndex];

    if (_currentCharIndex < (NSInteger)current.length) {
        _framePauseCounter++;
        if (_framePauseCounter >= framesPerChar) {
            _currentCharIndex++;
            _framePauseCounter = 0;
        }
    } else {
        _framePauseCounter++;
        if (_framePauseCounter >= pauseAfterLineFrames) {
            _framePauseCounter = 0;
            _isClearingPause = YES;
        }
    }

    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
