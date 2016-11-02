//
//  DMZTouchesWindow.m
//
//  Created by dmoroz0v on 02/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

#import "DMZTouchesWindow.h"

@interface DMZTouchView : NSObject

@property (nonatomic, strong) UITouch *touch;
@property (nonatomic, strong) UIView *view;

@end

@implementation DMZTouchView

@end

@interface DMZTouchesWindow ()

@property (nonatomic, strong) NSMutableArray<DMZTouchView *> *dmz_views;

@end

@implementation DMZTouchesWindow

- (void)dmz_setEnabled:(BOOL)enabled
{
	if (enabled && self.dmz_views == nil)
	{
		self.dmz_views = [[NSMutableArray alloc] init];
	}
	else if (!enabled && self.dmz_views != nil)
	{
		for (DMZTouchView *touchView in self.dmz_views)
		{
			[touchView.view removeFromSuperview];
		}

		self.dmz_views = nil;
	}
}

- (void)sendEvent:(UIEvent *)event
{
	if (self.dmz_views != nil)
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

		[self dmz_touchesBegan:[beganTouches copy]];
		[self dmz_touchesMoved:[movedTouches copy]];
		[self dmz_touchesEnded:[endedTouches copy]];
	}

	[super sendEvent:event];
}

- (DMZTouchView *)dmz_touchViewWithTouch:(UITouch *)touch
{
	for (DMZTouchView *touchView in self.dmz_views)
	{
		if (touchView.touch == touch)
		{
			return touchView;
		}
	}

	return nil;
}
- (void)dmz_touchesBegan:(NSSet<UITouch *> *)touches
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

		[self.dmz_views addObject:touchView];

		[self addSubview:view];
	}
}

- (void)dmz_touchesMoved:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchView *touchView = [self dmz_touchViewWithTouch:touch];
		touchView.view.center = [touchView.touch locationInView:self];
	}
}

- (void)dmz_touchesEnded:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchView *touchView = [self dmz_touchViewWithTouch:touch];
		[touchView.view removeFromSuperview];
		[self.dmz_views removeObject:touchView];
	}
}

@end
