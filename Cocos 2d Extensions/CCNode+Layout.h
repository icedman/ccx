//
//  CCNode+Layout.h
//  Cocos2d Extensions
//
//  Created by Marvin Sanchez on 5/6/13.
//
//

#import "CCNode.h"
#import "cocos2d.h"

typedef enum KLayoutOrientation
{
    kLayoutOrientationUnknown = 0,
    kLayoutOrientationHorizontal = 1,
    kLayoutOrientationVertical = 2
} tLayoutOrientation;

@interface CCNode (Layout)

- (void) updateLayout;
- (tLayoutOrientation) layoutOrientation;
- (void) addItem:(CCNode*)item;
- (void) addSpacer;

@end

@interface CXLayoutSpacer : CCNode
@end

@interface CXLayoutPlaceholder : CCNode

@property (retain) CCNode* targetNode;

- (id) initWithNode:(CCNode*) node;

@end

@interface CXVerticalContainer : CCNode
@end

@interface CXHorizontalContainer : CCNode
@end
