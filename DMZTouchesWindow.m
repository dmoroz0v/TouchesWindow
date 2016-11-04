//
//  DMZTouchesWindow.m
//
//  Created by dmoroz0v on 02/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

#import "DMZTouchesWindow.h"

// MARK: DMZTouchView

@interface DMZTouchView : UIView

- (void)setCoreCollor:(UIColor *)coreColor;
- (void)setForceCollor:(UIColor *)forceColor;
- (void)setForceRadius:(CGFloat)forceRadius;

@end

@implementation DMZTouchView
{
	UIView *_core;
	UIView *_force;
}

- (instancetype)initWithRadius:(CGFloat)radius
{
	CGRect frame = CGRectMake(0, 0, radius * 2, radius * 2);

	self = [super initWithFrame:frame];

	_force = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
	_force.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	_force.layer.masksToBounds = YES;
	_force.layer.cornerRadius = radius;
	[self addSubview:_force];

	_core = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
	_core.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	_core.layer.masksToBounds = YES;
	_core.layer.cornerRadius = radius;
	[self addSubview:_core];

	self.userInteractionEnabled = NO;

	return self;
}

- (void)setCoreCollor:(UIColor *)coreColor
{
	_core.backgroundColor = coreColor;
}

- (void)setForceCollor:(UIColor *)forceColor
{
	_force.backgroundColor = forceColor;
}

- (void)setForceRadius:(CGFloat)forceRadius
{
	CGFloat scale = 1.0 + 0.6 * forceRadius;
	_force.transform = CGAffineTransformMakeScale(scale, scale);
}

@end

// MARK: DMZTouchEntity

@interface DMZTouchEntity : NSObject

@property (nonatomic, strong) UITouch *touch;
@property (nonatomic, strong) DMZTouchView *view;

@end

@implementation DMZTouchEntity

@end

// MARK: DMZTouchesWindow

@implementation DMZTouchesWindow
{
	NSMutableArray<DMZTouchEntity *> *_dmz_views;
}

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

	if (_dmz_touchesEnabled && _dmz_views == nil)
	{
		_dmz_views = [[NSMutableArray alloc] init];
	}
	else if (!_dmz_touchesEnabled && _dmz_views != nil)
	{
		for (DMZTouchEntity *touchEntity in _dmz_views)
		{
			[touchEntity.view removeFromSuperview];
		}

		_dmz_views = nil;
	}
}

- (void)sendEvent:(UIEvent *)event
{
	if (_dmz_views != nil)
	{
		NSMutableSet *beganTouches = [NSMutableSet set];

		NSMutableSet *endedTouches = [NSMutableSet set];

		for (UITouch *touch in event.allTouches)
		{
			switch (touch.phase) {
				case UITouchPhaseBegan:
					[beganTouches addObject:touch];
					break;
				case UITouchPhaseEnded:
				case UITouchPhaseCancelled:
					[endedTouches addObject:touch];
					break;
				case UITouchPhaseMoved:
				case UITouchPhaseStationary:
					break;
			}
		}

		[self dmz_touchesBegan:[beganTouches copy]];
		[self dmz_touchesMoved:[event.allTouches copy]];
		[self dmz_touchesEnded:[endedTouches copy]];
	}

	[super sendEvent:event];
}

- (DMZTouchEntity *)dmz_touchEntityWithTouch:(UITouch *)touch
{
	for (DMZTouchEntity *touchEntity in _dmz_views)
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
		UIColor *forceColor = self.dmz_touchesForceColor;
		if (forceColor == nil)
		{
			CGFloat red, green, blue, alpha;
			[self.dmz_touchesColor getRed:&red green:&green blue:&blue alpha:&alpha];
			forceColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha / 2];
		}

		DMZTouchView *view = [[DMZTouchView alloc] initWithRadius:self.dmz_touchesRadius];
		[view setCoreCollor:self.dmz_touchesColor];
		[view setForceCollor:forceColor];
		view.layer.zPosition = FLT_MAX;

		DMZTouchEntity *touchEntity = [[DMZTouchEntity alloc] init];
		touchEntity.touch = touch;
		touchEntity.view = view;

		[_dmz_views addObject:touchEntity];

		[self addSubview:view];
	}
}

- (void)dmz_touchesMoved:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		CGFloat forceRadius = 0;
		if (!self.dmz_touchesForceDisabled)
		{
			forceRadius = (touch.force - 0.5) / (touch.maximumPossibleForce - 0.5);
			forceRadius = MAX(0, forceRadius);
		}

		DMZTouchEntity *touchEntity = [self dmz_touchEntityWithTouch:touch];
		touchEntity.view.center = [touchEntity.touch locationInView:self];
		[touchEntity.view setForceRadius:forceRadius];
	}
}

- (void)dmz_touchesEnded:(NSSet<UITouch *> *)touches
{
	for (UITouch *touch in touches)
	{
		DMZTouchEntity *touchEntity = [self dmz_touchEntityWithTouch:touch];
		[touchEntity.view removeFromSuperview];
		[_dmz_views removeObject:touchEntity];
	}
}

@end
