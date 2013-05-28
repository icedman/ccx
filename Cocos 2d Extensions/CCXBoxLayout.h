//
//  CCXBoxLayout.h
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/22/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum CCXBoxLayoutJustify {
    kBoxLayoutJustifyStart = 1,
    kBoxLayoutJustifyEnd,
    kBoxLayoutJustifyCenter,
    kBoxLayoutJustifySpaceBetween,
    kBoxLayoutJustifySpaceAround,
} tBoxLayoutJustify;

typedef enum CCXBoxLayoutAlign {
    kBoxLayoutAlignStart = 1,
    kBoxLayoutAlignEnd,
    kBoxLayoutAlignCenter,
    kBoxLayoutAlignStretch
} tBoxLayoutAlign;

typedef enum CCXBoxLayoutDirection {
    kBoxLayoutDirectionRow = 0,
    kBoxLayoutDirectionColumn
} tBoxLayoutDirection;


typedef enum CCXBoxLayoutVisibility {
    kBoxLayoutVisibilityShow = 0,
    kBoxLayoutVisibilityHide,
    kBoxLayoutVisibilityCollapse
} tBoxLayoutVisibility;

@interface CCXBoxLayoutItem : NSObject

@property (retain) NSMutableArray* items;

@property CGRect frame;
@property tBoxLayoutJustify justify;
@property tBoxLayoutAlign   align;
@property tBoxLayoutVisibility visibility;
@property UInt8 shrink;
@property UInt8 grow;
@property (readonly) CGRect computedFrame;
@property (readonly) CGRect effectiveFrame;

@property UInt32 tag;
@property (assign) CCNode *node;
@property (assign) CCXBoxLayoutItem *parent;
@property (readonly) CCXBoxLayoutItem *root;

- (id) initWithFrame:(CGRect)frame;
- (id) initWithNode:(CCNode*)node;
- (void) layout;
- (void) debugDraw;

- (void) addItem:(CCXBoxLayoutItem*)item;
- (CCXBoxLayoutItem*) itemByTag:(UInt32)tag;

@end

@interface CCXVerticalBoxItem : CCXBoxLayoutItem
@end

@interface CCXHorizontalBoxItem : CCXBoxLayoutItem
@end

@interface CCXFlexBoxItem : CCXBoxLayoutItem

@property tBoxLayoutDirection direction;

@end
