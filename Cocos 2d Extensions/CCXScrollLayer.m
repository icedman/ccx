//
//  CCXScrollLayer.m
//  Cocos2d Extensions
//
//  Created by Marvin Sanchez on 5/1/13.
//
//

#import "CCXScrollLayer.h"
#import "cocos2d.h"

#define SCROLL_FRICTION 0.95

@interface CCXScrollLayer ()
{
    Boolean             _isScrolling;
    CGPoint             _velocity;
    NSTimeInterval      _lastTime;
    Boolean             _beganTouchesInside;
    Float32             _pinchDistance;
    CGPoint             _touch1Location;
    CGPoint             _positionOffset;
    
    CGPoint             _previousTouch;
    NSTimeInterval      _previousTouchTime;
}
@end

@implementation CCXScrollLayer

@synthesize scrollPosition  = _scrollPosition;
@synthesize scrollArea      = _scrollArea;
@synthesize scrollFriction  = _scrollFriction;
@synthesize pressPosition   = _pressPosition;
@synthesize releasePosition = _releasePosition;
@synthesize dragPosition    = _dragPosition;
@synthesize zoom            = _zoom;
@synthesize enabled         = _enabled;
@synthesize hasTouches      = _hasTouches;

@synthesize consumeTouches  = _consumeTouches;

-(id) init
{
    if (self = [super init]) {

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
        self.mouseEnabled = YES;
#endif
        
        _scrollFriction = SCROLL_FRICTION;
        _enabled = TRUE;
    }
    return self;
}

- (void) onEnter
{
    [self scheduleUpdate];
    [super onEnter];
}

- (void) onExit
{
    [self unscheduleAllSelectors];
    [super onExit];
}

-(Boolean) touchBegan:(CGPoint) pos
{
    _hasTouches = YES;
    
    if (!_enabled)
        return NO;
    
    _pressPosition = pos;
    _releasePosition = pos;
    _positionOffset = pos;
    
    CGPoint p = pos;
    p.x -= self.position.x;
    p.y -= self.position.y;
    if (CGRectContainsPoint(CGRectMake(0,0,self.contentSize.width,self.contentSize.height), p)) {
        _beganTouchesInside = YES;
    }
    
    [self onTouchBegan];
    return _beganTouchesInside;
}

-(void) touchEnded
{
    _hasTouches = NO;
    
    if (!_enabled)
        return;
    
    [self onTouchEnded];

    if (_isScrolling && _beganTouchesInside) {
        _isScrolling = FALSE;
        [self onScrollEnded];
    }

    _beganTouchesInside = FALSE;
    
    NSTimeInterval td = _lastTime - _previousTouchTime;
    if (td < 1.0) {
        Float32 dd = ccpDistance(_pressPosition, _previousTouch);
        if (dd < 20.0) {
            [self onDoubleTap];
            _previousTouchTime = 0;
            return;
        }
    }
    
    _previousTouch = _pressPosition;
    _previousTouchTime = _lastTime;
}

-(void) touchMoved:(CGPoint) pos interval:(NSTimeInterval)interval
{
    if (!_enabled)
        return;
    
    if (!_beganTouchesInside)
        return;
    
    Float32 diffX = pos.x - _positionOffset.x;
    Float32 diffY = pos.y - _positionOffset.y;
    
    if (!_isScrolling) {
        _isScrolling = TRUE;
        [self onScrollBegan];
    }
    
    _scrollPosition.x += diffX;

//#ifdef __CC_PLATFORM_IOS
//    _scrollPosition.y += diffY;
//#elif defined(__CC_PLATFORM_MAC)
    _scrollPosition.y -= diffY;
//#endif
    
    _velocity.x = diffX / interval;
    _velocity.y = diffY / interval;
    
    _positionOffset = pos;
    _releasePosition = pos;
    _dragPosition = pos;
    
    [self onScrollUpdate];
    [self onTouchUpdate];
}

-( void ) scrollUpdate:( ccTime )dt
{
    _velocity.x *= _scrollFriction;
    _velocity.y *= _scrollFriction;

    if (fabs(_velocity.x) < 10 || fabs(_velocity.y) < 10) {
        _velocity = CGPointMake(0, 0);
        return;
    }

    _scrollPosition.x += _velocity.x * dt;
//#ifdef __CC_PLATFORM_IOS
//    _scrollPosition.y += _velocity.y * dt;
//#elif defined(__CC_PLATFORM_MAC)
    _scrollPosition.y -= _velocity.y * dt;
//#endif
    
    [self onScrollUpdate];
}

#ifdef __CC_PLATFORM_IOS

/*
-(BOOL)ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event
{
    NSLog(@"ccTouchBegan");
    return NO;
}

-(void) ccTouchMoved:( UITouch* )touch withEvent:( UIEvent* )event
{
}

-( void )ccTouchEnded:( UITouch* )touch withEvent:( UIEvent* )event
{
}
 */

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allUserTouches=[event allTouches];

    if(allUserTouches.count==1)
    {
        UITouch* touch1=[[allUserTouches allObjects] objectAtIndex:0];
        CGPoint touch1location=[touch1 locationInView:[touch1 view]];
        touch1location=[[CCDirector sharedDirector] convertToGL:touch1location];
        
        _lastTime = event.timestamp;
        [self touchBegan:touch1location];
        return;
    }
    
    if(allUserTouches.count==2)
    {
        UITouch* touch1=[[allUserTouches allObjects] objectAtIndex:0];
        UITouch* touch2=[[allUserTouches allObjects] objectAtIndex:1];
        
        CGPoint touch1location=[touch1 locationInView:[touch1 view]];
        CGPoint touch2location=[touch2 locationInView:[touch2 view]];
        
        touch1location=[[CCDirector sharedDirector] convertToGL:touch1location];
        touch2location=[[CCDirector sharedDirector] convertToGL:touch2location];
        
        _touch1Location = touch1location;
        _pinchDistance = ccpDistance(touch1location, touch2location);
        [self onZoomBegan];
    }
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allUserTouches=[event allTouches];
    
    if(allUserTouches.count==1)
    {
        UITouch* touch1=[[allUserTouches allObjects] objectAtIndex:0];
        CGPoint touch1location=[touch1 locationInView:[touch1 view]];
        NSTimeInterval time = event.timestamp;
        NSTimeInterval interval = time - _lastTime;
        _lastTime = time;
        
        touch1location=[[CCDirector sharedDirector] convertToGL:touch1location];
        [self touchMoved:touch1location interval:interval];
        return;
    }
    
    if(allUserTouches.count==2)
    {
        UITouch* touch1=[[allUserTouches allObjects] objectAtIndex:0];
        UITouch* touch2=[[allUserTouches allObjects] objectAtIndex:1];
        
        CGPoint touch1location=[touch1 locationInView:[touch1 view]];
        CGPoint touch2location=[touch2 locationInView:[touch2 view]];
        
        touch1location=[[CCDirector sharedDirector] convertToGL:touch1location];
        touch2location=[[CCDirector sharedDirector] convertToGL:touch2location];
        
        Float32 distance = ccpDistance(touch1location, touch2location);
        _zoom = _pinchDistance - distance;
        _pinchDistance = distance;
        
        [self onZoomUpdate];
    }
}

-( void )ccTouchesEnded:( UITouch* )touch withEvent:( UIEvent* )event
{
    [self touchEnded];
}

#elif defined(__CC_PLATFORM_MAC)
    
-(BOOL) ccMouseDown:(NSEvent *)event
{
    CGPoint pos = [[CCDirector sharedDirector] convertEventToGL:event];
    
    _lastTime = event.timestamp;
    
    [self touchBegan:pos];
    return (!_consumeTouches);
}

-(BOOL) ccMouseDragged:(NSEvent *)event
{
    CGPoint pos = [[CCDirector sharedDirector] convertEventToGL:event];
    
    NSTimeInterval time = event.timestamp;
    NSTimeInterval interval = time - _lastTime;
    _lastTime = time;
    
    [self touchMoved:pos interval:interval];
    return (!_consumeTouches);
}

-(BOOL) ccMouseUp:(NSEvent *)event
{
    [self touchEnded];
    return (!_consumeTouches);
}

#endif

- (Boolean) hasScrollVelocity
{
    return (_velocity.x != 0 || _velocity.y !=0);
}

- (Boolean) isScrolling
{
    return [self hasScrollVelocity] || _isScrolling;
}

- (void) onTouchBegan
{}

- (void) onTouchEnded
{}

- (void) onTouchUpdate
{}

- (void) onZoomBegan
{}

- (void) onZoomUpdate
{}

- (void) onScrollBegan
{}

- (void) onScrollUpdate
{}

- (void) onScrollEnded
{}

- (void) onDoubleTap
{}

- (void) update:(ccTime) dt
{
    if ([self hasScrollVelocity]) {
        [self scrollUpdate:dt];
    }
}

- (void) scaleVelocity:(Float32)f
{
    _velocity.x *= f;
    _velocity.y *= f;
}

@end
