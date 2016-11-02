#import "DMZTouchesWindow.h"

@interface DMZTouchView : NSObject

@property (nonatomic, strong) UITouch *touch;
@property (nonatomic, strong) UIView *view;

@end

@implementation DMZTouchView

@end

@interface DMZTouchesWindow ()

@property (nonatomic, strong) NSMutableArray<DMZTouchView *> *views;

@end

@implementation DMZTouchesWindow

- (void)setEnabled:(BOOL)enabled
{
	if (enabled && self.views == nil)
	{
		self.views = [[NSMutableArray alloc] init];
	}
	else if (!enabled && self.views != nil)
	{
		for (DMZTouchView *touchView in self.views)
		{
			[touchView.view removeFromSuperview];
		}

		self.views = nil;
	}
}

- (void)sendEvent:(UIEvent *)event
{
	if (self.views != nil)
	{
		NSMutableSet *beganTouches = [NSMutableSet set];
		NSMutableSet *movedTouches = [NSMutableSet set];
		NSMutableSet *endedTouches = [NSMutableSet set];
		
		for (UITouch *touch in event.allTouches)
		{
			if (touch.phase == UITouchPhaseBegan)
			{
				[beganTouches addObject:touch];
			}
			else if (touch.phase == UITouchPhaseMoved)
			{
				[movedTouches addObject:touch];
			}
			else
			{
				[endedTouches addObject:touch];
			}
		}

		[self touchesBegan:[beganTouches copy]];
		[self touchesMoved:[movedTouches copy]];
		[self touchesEnded:[endedTouches copy]];
	}

	[super sendEvent:event];
}

- (DMZTouchView *)touchViewWithTouch:(UITouch *)touch
{
	for (DMZTouchView *touchView in self.views)
	{
		if (touchView.touch == touch)
		{
			return touchView;
		}
	}

	return nil;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchView *touchView = [[DMZTouchView alloc] init];
		touchView.touch = touch;

		UIView *view = [[UIView alloc] init];
		view.frame = CGRectMake(0, 0, 40, 40);
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = 20;
		view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
		view.center = [touch locationInView:self];
		view.layer.zPosition = CGFLOAT_MAX;

		touchView.view = view;

		[self.views addObject:touchView];

		[self addSubview:view];
	}
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchView *touchView = [self touchViewWithTouch:touch];
		touchView.view.center = [touchView.touch locationInView:self];
	}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchView *touchView = [self touchViewWithTouch:touch];
		[touchView.view removeFromSuperview];
		[self.views removeObject:touchView];
	}
}

@end
