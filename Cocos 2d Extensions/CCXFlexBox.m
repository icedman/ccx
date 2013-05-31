//
//  CCXFlexBox.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "CCXFlexBox.h"
#import "cocos2d.h"

@interface CCXFlexBox ()

@property CGRect  originalFrame;
@property CGSize  computedSize;
@property CGPoint computedPosition;
@property CGPoint computedWorldPosition;
@property CGSize  minimumSize;

@property (readonly) Float32 mainSize;
@property (readonly) Float32 mainStart;
@property (readonly) Float32 mainEnd;
@property (readonly) Float32 crossSize;
@property (readonly) Float32 crossStart;
@property (readonly) Float32 crossEnd;

@end

@implementation CCXFlexBox

@synthesize computedFrame;

@synthesize tag         = _tag;
@synthesize frame       = _frame;
@synthesize align       = _align;
@synthesize justify     = _justify;
@synthesize visibility  = _visibility;
@synthesize shrink      = _shrink;
@synthesize grow        = _grow;

@synthesize items = _items;
@synthesize parent = _parent;
@synthesize root;
@synthesize isVisible;
@synthesize hasOverflow = _hasOverflow;

// private
@synthesize originalFrame    = _originalFrame;
@synthesize computedSize     = _computedSize;
@synthesize computedPosition = _computedPosition;
@synthesize computedWorldPosition = _computedWorldPosition;
@synthesize minimumSize      = _minimumSize;
@synthesize mainSize    = _mainSize;
@synthesize mainStart   = _mainStart;
@synthesize mainEnd     = _mainEnd;
@synthesize crossSize   = _crossSize;
@synthesize crossStart  = _crossStart;
@synthesize crossEnd    = _crossEnd;

- (void) dealloc
{
    [_items release];
    [super dealloc];
}

- (id) init
{
    if (self = [super init]) {
        _items = [[NSMutableArray alloc]init];
        
        // default size
        _frame = CGRectMake(0,0,0,0);
        
        _direction = kFlexBoxDirectionRow;
        _align = kFlexBoxAlignCenter;
        _justify = kFlexBoxJustifyCenter;
        _visibility = kFlexBoxVisibilityShow;
        _grow = 0;
        _shrink = 1;
        
        _minWidth = kFlexBoxAuto;
        _minHeight = kFlexBoxAuto;
    }
    return self;
}

- (CCXFlexBox*) root
{
    if (self.parent != nil)
        return [self.parent root];
    return self;
}

- (bool) isVisible
{
    bool visible = (self.visibility == kFlexBoxVisibilityShow);
    if (self.parent != nil) {
        visible = visible &&  self.parent.isVisible;
    }
    return visible;
}

- (CCXFlexBox*) itemByTag:(UInt32)tag
{
    if (_tag == tag)
        return self;

    for(CCXFlexBox *item in self.items) {
        CCXFlexBox *found = [item itemByTag:tag];
        if (found != nil)
            return found;
    }
    
    return nil;
}

- (CGRect) computedFrame
{
    CGRect r;
    r.origin = _computedWorldPosition;
    r.size = _computedSize;
    return r;
}

- (void) addItem:(CCXFlexBox*)item
{
    item.parent = self;
    [_items addObject:item];
}

- (void) updateMetrics:(tFlexBoxDirection) direction
{
    CGRect f;
    f.size = _computedSize;
    f.origin = _computedPosition;
    
    if (direction == kFlexBoxDirectionColumn) {
        Float32 t;
        t = f.origin.x;
        f.origin.x = f.origin.y;
        f.origin.y = t;
        t = f.size.width;
        f.size.width = f.size.height;
        f.size.height = t;
    }
    
    _mainStart = f.origin.x;
    _mainEnd = f.origin.x + f.size.width;
    _mainSize = _mainEnd - _mainStart;
    _crossStart = f.origin.y;
    _crossEnd = f.origin.y + f.size.height;
    _crossSize = _crossEnd - _crossStart;
}

- (void) debugDraw
{
    if (_visibility != kFlexBoxVisibilityShow)
        return;
    
    CGRect f = self.computedFrame;
    CGPoint pFrom = f.origin;
    CGPoint pTo = pFrom;
    pTo.x += f.size.width;
    pTo.y += f.size.height;
    
    CGSize sz = [CCDirector sharedDirector].winSize;
    pTo.y = sz.height - pTo.y;
    pFrom.y = sz.height - pFrom.y;
    
    ccDrawColor4B(255, 0, 255, 255);
    ccDrawRect(pFrom, pTo);

    {
        int border = 4;
        ccDrawColor4B(255, 255, 0, 255);
        pFrom.x += border;
        pFrom.y -= border;
        pTo.x -= border;
        pTo.y += border;
        ccDrawRect(pFrom, pTo);
    }
    
    for(CCXFlexBox *item in _items) {
        [item debugDraw];
    }
}

- (void) debugLog
{
    NSLog(@"%@", self);
    for(CCXFlexBox *item in _items) {
        [item debugLog];
    }
}

- (void) saveOriginalFrames
{
    _originalFrame = _frame;
    for (CCXFlexBox *item in _items) {
        [item saveOriginalFrames];
    }
}

- (void) restoreOriginalFrames
{
    _frame = _originalFrame;
    for (CCXFlexBox *item in _items) {
        [item restoreOriginalFrames];
    }
}

- (void) calculateSizes
{
    _computedSize = _frame.size;
    
    [self updateMetrics:_direction];
    
    Float32 ms = 0;
    Float32 cs = 0;
    for (CCXFlexBox *item in _items) {
        [item calculateSizes];
        [item updateMetrics:_direction];
        
        if (item.visibility == kFlexBoxVisibilityCollapse)
            continue;
        
        ms += item.mainSize;
        if (cs < item.crossSize)
            cs = item.crossSize;
    }
    
    if (_direction == kFlexBoxDirectionColumn)
        _minimumSize = CGSizeMake(cs,ms);
    else
        _minimumSize = CGSizeMake(ms, cs);
    
    if (ms < _mainSize)
        ms = _mainSize;
    if (cs < _crossSize)
        cs = _crossSize;
    
    CGSize os = _computedSize;
    
    if (_direction == kFlexBoxDirectionColumn)
        _computedSize = CGSizeMake(cs,ms);
    else
        _computedSize = CGSizeMake(ms,cs);
    
    if (_minHeight == kFlexBoxNone)
        _computedSize.height = os.height;
    if (_minWidth == kFlexBoxNone)
        _computedSize.width = os.width;
    
    if (_minHeight > 0 && _computedSize.height < _minHeight)
        _computedSize.height = _minHeight;
    if (_minWidth > 0 && _computedSize.width < _minWidth)
        _computedSize.width = _minWidth;
    
    // handle kFlexBoxAlignStretch (todo!)
    for (CCXFlexBox *item in _items) {
        tFlexBoxAlign align = _align;
        if (align == kFlexBoxAlignStretch) {
            CGSize itemSize = item.computedSize;
            if (_direction == kFlexBoxDirectionColumn)
                itemSize.width = cs;
            else
                itemSize.height = cs;
            item.computedSize = itemSize;
        }
    }
    
    // check overflow here
}

- (void) growItems
{
    [self updateMetrics:_direction];
    
    UInt16 totalGrow = 0;
    UInt16 totalShrink = 0;
    Float32 ms = 0;
    for (CCXFlexBox *item in _items) {
        
        if (item.visibility == kFlexBoxVisibilityCollapse)
            continue;
        
        [item growItems];
        [item updateMetrics:_direction];
        totalGrow += item.grow;
        totalShrink += item.shrink;
        ms += item.mainSize;
    }
    
    for(int loop=0; loop<2; loop++) {
        
        if (loop == 0 && (totalGrow == 0 || ms >= _mainSize))
            continue;

        if (loop == 1 && (totalShrink == 0 || ms <= _mainSize))
            continue;
        
        Float32 space = _mainSize - ms;
        for (CCXFlexBox *item in _items) {

            if (item.visibility == kFlexBoxVisibilityCollapse)
                continue;
            
            Float32 itemMainSize;
            
            if (loop == 0)
                itemMainSize = item.mainSize + (space * item.grow / totalGrow);
            else
                itemMainSize = item.mainSize + (space * item.shrink / totalShrink);
            
            CGSize sz = CGSizeMake(itemMainSize, item.crossSize);
            if (_direction == kFlexBoxDirectionColumn) {
                sz = CGSizeMake(item.crossSize,itemMainSize);
            }
            
            item.computedSize = sz;
            CGRect f = item.frame;
            f.size = sz;
            item.frame = f;
            
            [item calculateSizes];
            [item growItems];
        }
        
        CGSize sz = _minimumSize;
        if (_direction == kFlexBoxDirectionColumn)
            sz.height += space;
        else
            sz.width += space;
        _minimumSize = sz;
    }
}

- (void) justifyItems
{
    [self updateMetrics:_direction];
    
    int totalItems = 0;
    for(CCXFlexBox *item in _items) {
        if (item.visibility == kFlexBoxVisibilityCollapse)
            continue;
        totalItems++;
    }

    Float32 ms = 0;
    Float32 cs = 0;
    Float32 spacing = 0;
    
    Float32 availableMainSpace = _mainSize - _minimumSize.width;
    if (_direction == kFlexBoxDirectionColumn)
        availableMainSpace = _mainSize - _minimumSize.height;
    
    switch (_justify) {
        case kFlexBoxJustifyStart:
            break;

        case kFlexBoxJustifyEnd:
            ms += availableMainSpace;
            break;

        case kFlexBoxJustifyCenter:
            ms += availableMainSpace/2;
            break;
            
        case kFlexBoxJustifySpaceAround:
            ms = availableMainSpace / (totalItems + 1);
            spacing = ms;
            break;

        case kFlexBoxJustifySpaceBetween:
            if (totalItems > 1) {
                spacing = availableMainSpace / (totalItems - 1);
            } else {
                ms = availableMainSpace / 2;
            }
            break;
            
        default:
            break;
    }
    
    for(CCXFlexBox *item in _items) {

        if (item.visibility == kFlexBoxVisibilityCollapse)
            continue;
        
        [item updateMetrics:_direction];
        
        CGPoint p = ccp(ms,cs);
        if (_direction == kFlexBoxDirectionColumn) {
            p = ccp(cs, ms);
        }
        
        item.computedPosition = p;
        ms += item.mainSize;
        ms += spacing;
        
        [item justifyItems];
    }
}

- (void) alignItems
{
    [self updateMetrics:_direction];
    
    for(CCXFlexBox *item in _items) {
        
        [item updateMetrics:_direction];
        Float32 availableCrossSpace =_crossSize - item.crossSize;
        
        if (availableCrossSpace < 0)
            availableCrossSpace = 0;
        
        tFlexBoxAlign align = _align;
        // check for self alignment
        
        switch (align) {
            case kFlexBoxAlignStretch:
                break;
                
            case kFlexBoxAlignStart:
                break;

            case kFlexBoxAlignEnd: {
                
                CGPoint p = item.computedPosition;
                if (_direction == kFlexBoxDirectionColumn) {
                    p.x += availableCrossSpace;
                } else {
                    p.y += availableCrossSpace;
                }
                
                item.computedPosition = p;
                
            }
                break;
                
            case kFlexBoxAlignCenter: {
                
                CGPoint p = item.computedPosition;
                if (_direction == kFlexBoxDirectionColumn) {
                    p.x += availableCrossSpace/2;
                } else {
                    p.y += availableCrossSpace/2;
                }
                
                item.computedPosition = p;
                
            }
                break;
                                
            default:
                break;
        }
        
        [item alignItems];

    }
}

- (void) calculateWorldPositions:(CGPoint)p
{
    CGPoint wp = _computedPosition;
    wp.x += p.x;
    wp.y += p.y;
    _computedWorldPosition = wp;
    
    for(CCXFlexBox *item in _items) {
        [item calculateWorldPositions:wp];
    }
}

- (void) layout
{
    [[CCDirector sharedDirector].scheduler unscheduleAllForTarget:self];
    
    [self saveOriginalFrames];
    [self preLayout];
    
    [self calculateSizes];
    [self growItems];
    [self justifyItems];
    [self alignItems];
    [self calculateWorldPositions:_frame.origin];
    
    [self postLayout];
    [self restoreOriginalFrames];
    
    [self animate];
}

- (void) preLayout
{
    for(CCXFlexBox *item in _items) {
        [item preLayout];
    }
}

- (void) postLayout
{
    for(CCXFlexBox *item in _items) {
        [item postLayout];
    }
}


- (void) animate
{
    for(CCXFlexBox *item in _items) {
        [item animate];
    }
}

- (void) scheduleLayout
{
    [[CCDirector sharedDirector].scheduler unscheduleAllForTarget:self];
    [[CCDirector sharedDirector].scheduler scheduleSelector:@selector(layout) forTarget:self interval:0.1 paused:false];
}

- (id) copyWithZone:(NSZone *)zone
{
    CCXFlexBox *thisCopy = nil;
    
    if ([self isKindOfClass:[CCXFlexBoxNodeContainer class]]) {
        CCXFlexBoxNodeContainer *container = (CCXFlexBoxNodeContainer*)self;
        CCNode *nodeCopy = nil;
        
        if (container.node != nil) {
            if ([container.node respondsToSelector:@selector(copyWithZone:)]) {
                nodeCopy = [[container.node copy] autorelease];
            } else {
                nodeCopy = [[[CCNode alloc] init] autorelease];
                nodeCopy.contentSize = container.node.contentSize;
            }
            
            nodeCopy.tag = container.node.tag;
            [container.node.parent addChild:nodeCopy];
        }
        
        thisCopy = [[CCXFlexBoxNodeContainer alloc] initWithNode:nodeCopy];
        
    } else {
        thisCopy = [[CCXFlexBox alloc] init];
    }
    
    thisCopy.direction = self.direction;
    thisCopy.justify = self.justify;
    thisCopy.align = self.align;
    thisCopy.visibility = self.visibility;
    thisCopy.shrink = self.shrink;
    thisCopy.grow = self.grow;
    thisCopy.minWidth = self.minWidth;
    thisCopy.minHeight =self.minHeight;
    thisCopy.frame = self.frame;
    thisCopy.tag = self.tag;
    
    for(CCXFlexBox *item in self.items) {
        CCXFlexBox *itemCopy = [[item copy] autorelease];
        [thisCopy addItem:itemCopy];
    }
    
    return thisCopy;
}

@end

@interface CCXFlexBoxNodeContainer ()
{
    UInt8 _pt;
    UInt8 _pb;
    UInt8 _pr;
    UInt8 _pl;
    
    CGPoint _prevPosition;
}
@end

@implementation CCXFlexBoxNodeContainer

@synthesize padding         = _padding;
@synthesize paddingTop      = _paddingTop;
@synthesize paddingBottom   = _paddingBottom;
@synthesize paddingLeft     = _paddingLeft;
@synthesize paddingRight    = _paddingRight;
@synthesize enableAnimation = _enableAnimation;

@synthesize node = _node;

- (void) dealloc
{
    [_node release];
    [super dealloc];
}

- (id) initWithNode:(CCNode*) node
{
    if (self = [super init]) {
        _node = [node retain];
        _padding = 4;
    }
    return self;
}

- (void) preLayout
{
    _pt = _paddingTop;
    _pb = _paddingBottom;
    _pl = _paddingLeft;
    _pr = _paddingRight;
    
    if (_pt == 0)
        _pt = _padding;
    if (_pb == 0)
        _pb = _padding;
    if (_pl == 0)
        _pl = _padding;
    if (_pr == 0)
        _pr = _padding;
    
    _prevPosition = _node.position;
    _node.position = CGPointZero;
    self.frame = CGRectMake(0,0,_node.contentSize.width + _pl + _pr,_node.contentSize.height + _pt + _pb);
    
    [super preLayout];
}

- (void) postLayout
{
    CGPoint p = [_node convertToNodeSpace:self.computedWorldPosition];
    p.x += _pl;
    p.y += _pt;
    
    // screen space
    CGSize sz = [CCDirector sharedDirector].winSize;
    p.y = sz.height - p.y;
    
    _node.position = p;    
    _node.visible = self.isVisible;
    
    [super postLayout];
}

- (void) animate
{
    if (!CGPointEqualToPoint(_prevPosition, CGPointZero) && _enableAnimation) {
        CGPoint toPoint = _node.position;
        _node.position = _prevPosition;
        [_node.actionManager removeAllActionsFromTarget:_node];
        [_node runAction:[CCMoveTo actionWithDuration:0.15 position: toPoint]];
    }

    [super animate];
}

@end

