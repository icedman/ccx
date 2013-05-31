//
//  CCXScrollLayer.h
//  Cocos2d Extensions
//
//  Created by Marvin Sanchez on 5/1/13.
//
//

#import "CCLayer.h"

@interface CCXScrollLayer : CCLayer

@property CGPoint   scrollPosition;
@property CGRect    scrollArea;
@property Float32   scrollFriction;
@property CGPoint   pressPosition;
@property CGPoint   releasePosition;
@property CGPoint   dragPosition;
@property Float32   zoom;
@property bool      consumeTouches;
@property bool      hasTouches;
@property bool      enabled;

- (void) onTouchBegan;
- (void) onTouchUpdate;
- (void) onTouchEnded;
- (void) onScrollBegan;
- (void) onScrollUpdate;
- (void) onScrollEnded;
- (void) onDoubleTap;

- (Boolean) hasScrollVelocity;
- (Boolean) isScrolling;
- (void) scaleVelocity:(Float32)f;

@end
