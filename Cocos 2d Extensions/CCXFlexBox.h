//
//  CCXFlexBox.h
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum CCXFlexBoxJustify {
    kFlexBoxJustifyStart = 1,
    kFlexBoxJustifyEnd,
    kFlexBoxJustifyCenter,
    kFlexBoxJustifySpaceBetween,
    kFlexBoxJustifySpaceAround,
} tFlexBoxJustify;

typedef enum CCXFlexBoxAlign {
    kFlexBoxAlignStart = 1,
    kFlexBoxAlignEnd,
    kFlexBoxAlignCenter,
    kFlexBoxAlignStretch
} tFlexBoxAlign;

typedef enum CCXFlexBoxDirection {
    kFlexBoxDirectionRow = 0,
    kFlexBoxDirectionColumn
} tFlexBoxDirection;


typedef enum CCXFlexBoxVisibility {
    kFlexBoxVisibilityShow = 0,
    kFlexBoxVisibilityHide,
    kFlexBoxVisibilityCollapse
} tFlexBoxVisibility;

typedef enum CCXFlexBoxSize {
    kFlexBoxAuto = -1,  // size is determined by children sizes
    kFlexBoxNone = 0    // size is determined by available space
                        // number greater than 0 ~ size is determined by number
} tFlexBoxSize;

@interface CCXFlexBox : NSObject

@property UInt32 tag;

@property CGRect frame;
@property (readonly) CGRect computedFrame;

@property tFlexBoxDirection  direction;
@property tFlexBoxJustify    justify;
@property tFlexBoxAlign      align;
@property tFlexBoxVisibility visibility;
@property UInt8 shrink;
@property UInt8 grow;
@property tFlexBoxSize minWidth;
@property tFlexBoxSize minHeight;

@property (readonly) NSMutableArray *items;

@property (assign) CCXFlexBox *parent;
@property (readonly) CCXFlexBox *root;
@property (readonly) bool isVisible;
@property (readonly) bool hasOverflow;

- (id) init;
- (void) debugDraw;
- (void) debugLog;
- (void) addItem:(CCXFlexBox*)item;
- (void) layout;
- (void) scheduleLayout;
- (CCXFlexBox*) itemByTag:(UInt32)tag;

- (void) preLayout;
- (void) postLayout;
- (void) animate;

@end

@interface CCXFlexBoxNodeContainer : CCXFlexBox

@property UInt8 padding;
@property UInt8 paddingTop;
@property UInt8 paddingBottom;
@property UInt8 paddingLeft;
@property UInt8 paddingRight;
@property bool enableAnimation;

@property (retain) CCNode* node;

- (id) initWithNode:(CCNode*) node;

@end