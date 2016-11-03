//
//  DMZTouchesWindow.m
//
//  Created by dmoroz0v on 02/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

#import "DMZTouchesWindow.h"

@interface DMZTouchEntity : NSObject

@property (nonatomic, strong) UITouch *touch;
@property (nonatomic, strong) UIView *view;

@end

@implementation DMZTouchEntity

@end

@interface DMZTouchesWindow ()

@property (nonatomic, strong) NSMutableArray<DMZTouchEntity *> *dmz_views;

@end

@implementation DMZTouchesWindow

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	[self setupDefaults];

	return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self == nil)
	{
		return nil;
	}

	[self setupDefaults];

	return self;
}

- (void)setupDefaults
{
	_dmz_touchesRadius = 20;
	_dmz_touchesColor = [UIColor colorWithWhite:0 alpha:0.5];
}

-(void)setDmz_touchesEnabled:(CGFloat)dmz_touchesEnabled
{
	_dmz_touchesEnabled = dmz_touchesEnabled;

	if (_dmz_touchesEnabled && self.dmz_views == nil)
	{
		self.dmz_views = [[NSMutableArray alloc] init];
	}
	else if (!_dmz_touchesEnabled && self.dmz_views != nil)
	{
		for (DMZTouchEntity *touchEntity in self.dmz_views)
		{
			[touchEntity.view removeFromSuperview];
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
			else if (touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary)
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

- (DMZTouchEntity *)dmz_touchEntityWithTouch:(UITouch *)touch
{
	for (DMZTouchEntity *touchEntity in self.dmz_views)
	{
		if (touchEntity.touch == touch)
		{
			return touchEntity;
		}
	}

	return nil;
}
	
- (void)dmz_touchesBegan:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchEntity *touchEntity = [[DMZTouchEntity alloc] init];
		touchEntity.touch = touch;

		UIView *view = [[UIView alloc] init];
		view.frame = CGRectMake(0, 0, self.dmz_touchesRadius * 2, self.dmz_touchesRadius * 2);
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = self.dmz_touchesRadius;
		view.backgroundColor = self.dmz_touchesColor;
		view.center = [touch locationInView:self];
		view.layer.zPosition = FLT_MAX;

		touchEntity.view = view;

		[self.dmz_views addObject:touchEntity];

		[self addSubview:view];
	}
}

- (void)dmz_touchesMoved:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchEntity *touchEntity = [self dmz_touchEntityWithTouch:touch];
		touchEntity.view.center = [touchEntity.touch locationInView:self];
	}
}

- (void)dmz_touchesEnded:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchEntity *touchEntity = [self dmz_touchEntityWithTouch:touch];
		[touchEntity.view removeFromSuperview];
		[self.dmz_views removeObject:touchEntity];
	}
}

@end
