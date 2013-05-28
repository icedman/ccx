//
//  CCXBoxLayout.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/22/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "CCXBoxLayout.h"
#import "cocos2d.h"

#define CCX_DEFAULT_FRAME_WIDTH 2
#define CCX_DEFAULT_FRAME_HEIGHT 2

@protocol CCXLayoutHandler <NSObject>

- (void) calculateSize;
- (void) calculateMaximumSize;
- (void) calculatePosition;

@end

@interface CCXBoxLayoutItem ()

@property CGSize  minimumSize;
@property CGSize  maximumSize;
@property CGSize  computedSize;
@property CGPoint computedPosition;
@property CGPoint computedWorldPosition;
@property CGRect  originalFrame;

@property NSMutableArray *itemSizes;

@end

@implementation CCXBoxLayoutItem

@synthesize frame   = _frame;
@synthesize justify = _justify;
@synthesize align   = _align;
@synthesize visibility = _visibility;
@synthesize shrink  = _shrink;
@synthesize grow    = _grow;

@synthesize items = _items;
@synthesize node  = _node;
@synthesize tag   = _tag;

@synthesize originalFrame    = _originalFrame;
@synthesize minimumSize      = _minimumSize;
@synthesize maximumSize      = _maximumSize;
@synthesize computedSize     = _computedSize;
@synthesize computedPosition = _computedPosition;
@synthesize computedWorldPosition = _computedWorldPosition;

@synthesize parent = _parent;

- (void) dealloc
{
    [_items release];
    [super dealloc];
}

- (id) init
{
    if (self = [self initWithFrame:CGRectMake(0,0,CCX_DEFAULT_FRAME_WIDTH,CCX_DEFAULT_FRAME_HEIGHT)]) {
    }
    return self;
}

// designated initializer
- (id) initWithFrame:(CGRect)frame
{
    if (self = [super init]) {
        _items = [[NSMutableArray alloc]init];
        _justify = kBoxLayoutJustifyCenter;
        _align = kBoxLayoutAlignCenter;
        _visibility = kBoxLayoutVisibilityShow;
        _frame = frame;
        _grow = 0;
        _shrink = 1;
    }
    return self;
}

- (id) initWithNode:(CCNode*)n
{
    if (self = [self initWithFrame:CGRectMake(0,0,CCX_DEFAULT_FRAME_WIDTH,CCX_DEFAULT_FRAME_HEIGHT)]) {
        _node = n;
    }
    return self;
}

- (CCXBoxLayoutItem*) root
{
    if (self.parent != nil)
        return [self.parent root];
    return self;
}

- (void) addItem:(CCXBoxLayoutItem*)item
{
    item.parent = self;
    [self.items addObject:item];
    
}

- (CCXBoxLayoutItem*) itemByTag:(UInt32)tag
{
    if (_tag == tag)
        return self;
    
    for(CCXBoxLayoutItem *item in self.items) {
        if (item.tag == tag)
            return item;
    }
    
    // go deep
    for(CCXBoxLayoutItem *item in self.items) {
        CCXBoxLayoutItem *found = [item itemByTag:tag];
        if (found != nil)
            return found;
    }
    
    return nil;
}

- (CGRect) computedFrame
{
    CGRect r;
    r.origin = _computedPosition;
    r.size = _computedSize;
    return r;
}

- (CGRect) effectiveFrame
{
    CGRect r;
    r.origin = _computedPosition;
    r.size = _maximumSize;
    return r;
}

- (void) calculateSize
{
    CGSize s = self.frame.size;
    
    if (self.node != nil) {
        if (s.width < self.node.contentSize.width)
            s.width = self.node.contentSize.width;
        if (s.height < self.node.contentSize.height)
            s.height = self.node.contentSize.height;
    }
    
    self.computedSize = s;
    self.minimumSize = s;
}

- (void) calculatePosition
{
    self.computedPosition = self.frame.origin;
}

- (void) calculateMaximumSize
{
    // self.maximumSize = self.computedSize;
}

- (void) calculateWorldPosition:(CGPoint)pos
{
    CGPoint p = self.computedPosition;
    p.x += pos.x;
    p.y += pos.y;
    self.computedWorldPosition = p;
    
    for(CCXBoxLayoutItem *item in self.items) {
        [item calculateWorldPosition:p];
    }
}

- (void) positionNodes
{
    if (self.node != nil) {
        self.node.position = CGPointZero;
        CGPoint p = [self.node convertToNodeSpace:self.computedWorldPosition];
        p.x += self.maximumSize.width/2 - self.node.contentSize.width/2;
        p.y += self.maximumSize.height/2 - self.node.contentSize.height/2;
        self.node.position = p;
        self.node.visible = (self.visibility == kBoxLayoutVisibilityShow);
    }
    for(CCXBoxLayoutItem *item in self.items) {
        [item positionNodes];
    }
}

- (void) layout
{
    // called only at root
    assert(self.parent == nil);
    
    _computedPosition = self.frame.origin;
    _maximumSize = self.frame.size;
    [self calculateSize];
    [self calculateMaximumSize];
    [self calculatePosition];
    [self calculateWorldPosition: CGPointZero];
    [self positionNodes];
}

- (void) debugDraw
{
    if (self.visibility != kBoxLayoutVisibilityShow)
        return;
    
    CGSize sz = self.maximumSize;
    
    CGPoint from = self.computedWorldPosition;
    CGPoint to = self.computedWorldPosition;
    to.x += sz.width;
    to.y += sz.height;
    
    ccDrawColor4B(255, 255, 0, 255);
    //ccDrawSolidRect(from, to, ccc4f(0.5,0,0.5,1.0));
    ccDrawRect(from, to);
    
#if FALSE
    ccDrawLine(from, to);
    int x = from.x;
    from.x = to.x;
    to.x = x;
    ccDrawLine(from, to);
#endif
    
    if (self.node != nil) {
        CGSize s = self.node.contentSize;
        CGPoint center = from;
        center.x += sz.width/2;
        center.y += sz.height/2;
        from = center;
        from.x -= s.width/2 - 1;
        from.y -= s.height/2 - 1;
        to = from;
        to.x += s.width - 2;
        to.y += s.height - 2;
        // ccDrawColor4B(255, 0, 0, 255);
        // ccDrawRect(from, to);
    }
    
    for(CCXBoxLayoutItem *item in _items) {
        [item debugDraw];
    }
}

@end

@interface CCXVerticalLayoutHandler : NSObject<CCXLayoutHandler>
@property (assign) CCXBoxLayoutItem *target;
@end

@implementation CCXVerticalLayoutHandler

@synthesize target;

- (void) calculateSize
{
    // save original frame size
    for(CCXBoxLayoutItem *item in target.items) {
        item.originalFrame = item.frame;
    }
    
    // first pass ~ get preferred sizes
    CGSize s;
    s.width = 0;
    s.height = 0;
    int totalGrow = 0;
    int totalShrink = 0;
    for(CCXBoxLayoutItem *item in target.items) {
        [item calculateSize];
        
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        
        s.height += item.computedSize.height;
        if (s.width < item.computedSize.width) {
            s.width = item.computedSize.width;
        }
        totalGrow += item.grow;
        totalShrink += item.shrink;
    }
    
    target.minimumSize = s;
    
    if (s.width < target.frame.size.width)
        s.width = target.frame.size.width;
    if (s.height < target.frame.size.height)
        s.height = target.frame.size.height;
    
    target.computedSize = s;
    
    // second pass ~ grow
    if (target.minimumSize.height < target.computedSize.height && totalGrow > 0) {
        Float32 space = target.computedSize.height - target.minimumSize.height;
        for(CCXBoxLayoutItem *item in target.items) {
            
            if (item.visibility == kBoxLayoutVisibilityCollapse)
                continue;
            
            Float32 ratio = (Float32)item.grow / totalGrow;
            CGSize fs = item.computedSize;
            fs.height += space * ratio;
            CGRect r = item.frame;
            r.size = fs;
            item.frame = r;
            [item calculateSize];
        }
        CGSize s = target.minimumSize;
        s.height += space;
        target.minimumSize = s;
    }
    
    // third pass ~ stretch
    if (target.align == kBoxLayoutAlignStretch) {
        for(CCXBoxLayoutItem *item in target.items) {
            CGSize fs = item.computedSize;
            if (fs.width < target.computedSize.width) {
                fs.width = target.computedSize.width;
                CGRect r = item.frame;
                r.size = fs;
                item.frame = r;
                [item calculateSize];
            }
        }
    }
    
    // restore original frame size
    for(CCXBoxLayoutItem *item in target.items) {
        item.frame = item.originalFrame;
    }
}

- (void) calculateMaximumSize
{
    CGSize s;
    s.width = 0;
    s.height = 0;
    int totalShrink = 0;
    for(CCXBoxLayoutItem *item in target.items) {
        item.maximumSize = item.computedSize;
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        s.height += item.computedSize.height;
        if (s.width < item.computedSize.width) {
            s.width = item.computedSize.width;
        }
        totalShrink += item.shrink;
    }
    
    Float32 space = target.maximumSize.height - s.height;
    for(CCXBoxLayoutItem *item in target.items) {
        if (space < 0) {
            if (item.visibility == kBoxLayoutVisibilityCollapse)
                continue;
            CGSize sz = item.maximumSize;
            sz.height += space * item.shrink / totalShrink;
            item.maximumSize = sz;
        }
        [item calculateMaximumSize];
    }
}

- (void) calculatePosition
{
    int yy = 0;
    int ys = 0;
    int tc = 0;
    
    for(CCXBoxLayoutItem *item in target.items) {
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        tc++;
    }
    
    switch (target.justify) {
        case kBoxLayoutJustifyStart: {
            yy = target.maximumSize.height - target.minimumSize.height;
            break;
        }
        case kBoxLayoutJustifyCenter: {
            yy = (target.maximumSize.height - target.minimumSize.height) / 2;
            break;
        }
        case kBoxLayoutJustifySpaceAround: {
            yy = (target.maximumSize.height - target.minimumSize.height) / (tc + 1);
            ys = yy;
            break;
        }
        case kBoxLayoutJustifySpaceBetween: {
            if (target.items.count > 1) {
                ys = (target.maximumSize.height - target.minimumSize.height) / (tc - 1);
            } else {
                yy = (target.maximumSize.height - target.minimumSize.height) / 2;
            }
            break;
        }
        default:
            break;
    }
    
    if (ys < 0) {
        ys = 0;
        yy = 0;
    }
    
    // reversed so first objects are on top
    for(CCXBoxLayoutItem *item in [target.items reverseObjectEnumerator]) {
        [item calculatePosition];
        item.computedPosition = ccp(0, yy);
        
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        
        yy += item.maximumSize.height;
        yy += ys;
    }
    
    target.computedPosition = target.frame.origin;
    
    if (target.align == kBoxLayoutAlignEnd) {
        for(CCXBoxLayoutItem *item in target.items) {
            CGPoint p = item.computedPosition;
            p.x = target.maximumSize.width - item.maximumSize.width;
            item.computedPosition = p;
        }
    }
    
    if (target.align == kBoxLayoutAlignCenter) {
        for(CCXBoxLayoutItem *item in target.items) {
            CGPoint p = item.computedPosition;
            p.x = target.maximumSize.width/2 - item.maximumSize.width/2;
            item.computedPosition = p;
        }
    }
}

@end


@interface CCXHorizontalLayoutHandler : NSObject<CCXLayoutHandler>
@property (assign) CCXBoxLayoutItem *target;
@end

@implementation CCXHorizontalLayoutHandler

@synthesize target;

- (void) calculateSize
{
    // save original frame size
    for(CCXBoxLayoutItem *item in target.items) {
        item.originalFrame = item.frame;
    }
    
    // first pass ~ get preferred sizes
    CGSize s;
    s.width = 0;
    s.height = 0;
    int totalGrow = 0;
    int totalShrink = 0;
    for(CCXBoxLayoutItem *item in target.items) {
        [item calculateSize];
        
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        
        s.width += item.computedSize.width;
        if (s.height < item.computedSize.height) {
            s.height = item.computedSize.height;
        }
        totalGrow += item.grow;
        totalShrink += item.shrink;
    }
    
    target.minimumSize = s;
    
    if (s.width < target.frame.size.width)
        s.width = target.frame.size.width;
    if (s.height < target.frame.size.height)
        s.height = target.frame.size.height;
    
    target.computedSize = s;
    
    // second pass ~ grow
    if (target.minimumSize.width < target.computedSize.width && totalGrow > 0) {
        Float32 space = target.computedSize.width - target.minimumSize.width;
        for(CCXBoxLayoutItem *item in target.items) {
            
            if (item.visibility == kBoxLayoutVisibilityCollapse)
                continue;
            
            Float32 ratio = (Float32)item.grow / totalGrow;
            CGSize fs = item.computedSize;
            fs.width += space * ratio;
            CGRect r = item.frame;
            r.size = fs;
            item.frame = r;
            [item calculateSize];
        }
        CGSize s = target.minimumSize;
        s.width += space;
        target.minimumSize = s;
    }
    
    // third pass ~ stretch
    if (target.align == kBoxLayoutAlignStretch) {
        for(CCXBoxLayoutItem *item in target.items) {
            CGSize fs = item.computedSize;
            if (fs.height < target.computedSize.height) {
                fs.height = target.computedSize.height;
                CGRect r = item.frame;
                r.size = fs;
                item.frame = r;
                [item calculateSize];
            }
        }
    }
    
    // restore original frame size
    for(CCXBoxLayoutItem *item in target.items) {
        item.frame = item.originalFrame;
    }
}

- (void) calculateMaximumSize
{
    CGSize s;
    s.width = 0;
    s.height = 0;
    int totalShrink = 0;
    for(CCXBoxLayoutItem *item in target.items) {
        item.maximumSize = item.computedSize;
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        s.width += item.computedSize.width;
        if (s.height < item.computedSize.height) {
            s.height = item.computedSize.height;
        }
        totalShrink += item.shrink;
    }
    
    Float32 space = target.maximumSize.width - s.width;
    for(CCXBoxLayoutItem *item in target.items) {
        if (s.width > target.maximumSize.width && totalShrink > 0) {
            if (item.visibility == kBoxLayoutVisibilityCollapse)
                continue;
            CGSize sz = item.maximumSize;
            sz.width += space * item.shrink / totalShrink;
            item.maximumSize = sz;
        }
        [item calculateMaximumSize];
        
    }
}

- (void) calculatePosition
{
    int xx = 0;
    int xs = 0;
    int tc = 0;
    
    for(CCXBoxLayoutItem *item in target.items) {
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        tc++;
    }
    
    switch (target.justify) {
        case kBoxLayoutJustifyEnd: {
            xx = target.maximumSize.width - target.minimumSize.width;
            break;
        }
        case kBoxLayoutJustifyCenter: {
            xx = (target.maximumSize.width - target.minimumSize.width) / 2;
            break;
        }
        case kBoxLayoutJustifySpaceAround: {
            xx = (target.maximumSize.width - target.minimumSize.width) / (tc + 1);
            xs = xx;
            break;
        }
        case kBoxLayoutJustifySpaceBetween: {
            if (target.items.count > 1) {
                xs = (target.maximumSize.width - target.minimumSize.width) / (tc - 1);
            } else {
                xx = (target.maximumSize.width - target.minimumSize.width) / 2;
            }
            break;
        }
        default:
            break;
    }
    
    if (xs < 0) {
        xs = 0;
        xx = 0;
    }
    
    for(CCXBoxLayoutItem *item in target.items) {
        [item calculatePosition];
        item.computedPosition = ccp(xx, 0);
        
        if (item.visibility == kBoxLayoutVisibilityCollapse)
            continue;
        
        xx += item.maximumSize.width;
        xx += xs;
    }
    
    target.computedPosition = target.frame.origin;
    
    if (target.align == kBoxLayoutAlignStart) {
        for(CCXBoxLayoutItem *item in target.items) {
            CGPoint p = item.computedPosition;
            p.y = target.maximumSize.height - item.maximumSize.height;
            item.computedPosition = p;
        }
    }
    
    if (target.align == kBoxLayoutAlignCenter) {
        for(CCXBoxLayoutItem *item in target.items) {
            CGPoint p = item.computedPosition;
            p.y = target.maximumSize.height/2 - item.maximumSize.height/2;
            item.computedPosition = p;
        }
    }
}

@end

@interface CCXVerticalBoxItem ()
{
    CCXVerticalLayoutHandler *_layoutHandler;
}
@end

@implementation CCXVerticalBoxItem

- (void) dealloc
{
    [_layoutHandler release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _layoutHandler = [[CCXVerticalLayoutHandler alloc] init];
        _layoutHandler.target = self;
    }
    return self;
}

- (id) initWithNode:(CCNode*)node
{
    if (self = [super initWithNode:node]) {
        _layoutHandler = [[CCXVerticalLayoutHandler alloc] init];
        _layoutHandler.target = self;
    }
    return self;
}

- (void) calculateSize
{
    [_layoutHandler calculateSize];
}

- (void) calculateMaximumSize
{
    [_layoutHandler calculateMaximumSize];
}

- (void) calculatePosition
{
    [_layoutHandler calculatePosition];
}

@end

@interface CCXHorizontalBoxItem ()
{
    CCXHorizontalLayoutHandler *_layoutHandler;
}
@end

@implementation CCXHorizontalBoxItem

- (void) dealloc
{
    [_layoutHandler release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _layoutHandler = [[CCXHorizontalLayoutHandler alloc] init];
        _layoutHandler.target = self;
    }
    return self;
}

- (id) initWithNode:(CCNode*)node
{
    if (self = [super initWithNode:node]) {
        _layoutHandler = [[CCXHorizontalLayoutHandler alloc] init];
        _layoutHandler.target = self;
    }
    return self;
}

- (void) calculateSize
{
    [_layoutHandler calculateSize];
}

- (void) calculateMaximumSize
{
    [_layoutHandler calculateMaximumSize];
}

- (void) calculatePosition
{
    [_layoutHandler calculatePosition];
}

@end

@interface CCXFlexBoxItem ()
{
    CCXHorizontalLayoutHandler  *_row;
    CCXVerticalLayoutHandler    *_column;
}
@end

@implementation CCXFlexBoxItem

@synthesize direction = _direction;

- (void) dealloc
{
    [_row release];
    [_column release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _row = [[CCXHorizontalLayoutHandler alloc] init];
        _row.target = self;
        _column = [[CCXVerticalLayoutHandler alloc] init];
        _column.target = self;
        _direction = kBoxLayoutDirectionRow;
    }
    return self;
}

- (id) initWithNode:(CCNode*)node
{
    if (self = [super initWithNode:node]) {
        _row = [[CCXHorizontalLayoutHandler alloc] init];
        _row.target = self;
        _column = [[CCXVerticalLayoutHandler alloc] init];
        _column.target = self;
        _direction = kBoxLayoutDirectionRow;
    }
    return self;
}

- (void) calculateSize
{
    if (_direction == kBoxLayoutDirectionRow)
        [_row calculateSize];
    else
        [_column calculateSize];
}

- (void) calculateMaximumSize
{
    if (_direction == kBoxLayoutDirectionRow)
        [_row calculateMaximumSize];
    else
        [_column calculateMaximumSize];
}

- (void) calculatePosition
{
    if (_direction == kBoxLayoutDirectionRow)
        [_row calculatePosition];
    else
        [_column calculatePosition];
}

@end


