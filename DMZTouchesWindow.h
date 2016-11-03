//
//  DMZTouchesWindow.h
//
//  Created by dmoroz0v on 02/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

#import <UIKit/UIWindow.h>

@interface DMZTouchesWindow : UIWindow

// Color of touch circles. Default is black with 50% opacity
@property (nonatomic, strong) UIColor *dmz_touchesColor;

// Radius of touch circles. Default is 20.0
@property (nonatomic, assign) CGFloat dmz_touchesRadius;

// Determines visible touch circles. YES - touch circles are visible.
// NO - touch circles are not visible. Defailt is NO
@property (nonatomic, assign) CGFloat dmz_touchesEnabled;

@end
