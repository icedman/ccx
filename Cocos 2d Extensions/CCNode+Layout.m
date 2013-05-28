//
//  CCNode+Layout.m
//  Cocos2d Extensions
//
//  Created by Marvin Sanchez on 5/6/13.
//
//

#import "CCNode+Layout.h"

@implementation CXLayoutPlaceholder

@synthesize targetNode = _targetNode;

- (void) dealloc
{
    [_targetNode release];
    [super dealloc];
}

- (id) initWithNode:(CCNode *)node
{
    if (self = [self init]) {
        self.targetNode = node;
        self.contentSize = node.contentSize;
    }
    return self;
}

- (void) updateLayout
{
    self.contentSize = self.targetNode.contentSize;
    self.targetNode.position = self.position;
}

@end


@implementation CXLayoutSpacer

@end

@implementation CCNode (Layout)

- (void) addItem:(CCNode*)item
{
    [self addChild:[[[CXLayoutPlaceholder alloc] initWithNode:item] autorelease]];
}

- (void) addSpacer
{
    [self addChild:[[[CXLayoutSpacer alloc] init] autorelease]];
}

- (void) updateHorizontalLayout
{
    int spacerNodeCount = 0;
    Float32 requiredSpace = 0;
    for(CCNode *n in self.children) {
        if ([n isKindOfClass:[CXLayoutSpacer class]]) {
            spacerNodeCount ++;
        }
        requiredSpace += n.contentSize.width;
    }
    
    Float32 spaceAvailable = self.contentSize.width - requiredSpace;
    Float32 offset=-self.contentSize.width/2;
    
    Float32 spacer = 0;
    if (spaceAvailable > 0 && spacerNodeCount > 0) {
        spacer = spaceAvailable / spacerNodeCount;
        spaceAvailable = 0;
    }
    
    offset += (spaceAvailable)/2;
    for(CCNode *n in self.children) {
        offset += n.contentSize.width/2;
        CGPoint p = n.position;
        p.x = offset;
        n.position = p;
        offset += n.contentSize.width/2;
        if ([n isKindOfClass:[CXLayoutSpacer class]]) {
            offset += spacer;
        }
    }
}

- (void) updateVerticalLayout
{
    int spacerNodeCount = 0;
    Float32 requiredSpace = 0;
    for(CCNode *n in self.children) {
        if ([n isKindOfClass:[CXLayoutSpacer class]]) {
            spacerNodeCount ++;
        }
        if ([n isKindOfClass:[CXLayoutPlaceholder class]]) {
            [n updateLayout];
        }
        requiredSpace += n.contentSize.height;
    }
    
    Float32 spaceAvailable = self.contentSize.height - requiredSpace;
    Float32 offset=-self.contentSize.height/2;
    
    Float32 spacer = 0;
    if (spaceAvailable > 0 && spacerNodeCount > 0) {
        spacer = spaceAvailable / spacerNodeCount;
        spaceAvailable = 0;
    }
    
    offset += (spaceAvailable)/2;
    for(CCNode *n in self.children) {
        offset += n.contentSize.height/2;
        CGPoint p = n.position;
        p.y = -offset;
        n.position = p;
        offset += n.contentSize.height/2;
        if ([n isKindOfClass:[CXLayoutSpacer class]]) {
            offset += spacer;
        }
    }
}

- (void) updateLayout
{    
    switch ([self layoutOrientation]) {
        case kLayoutOrientationHorizontal:
            [self updateHorizontalLayout];
            break;

        case kLayoutOrientationVertical:
            [self updateVerticalLayout];
            break;
            
        default:
            break;
    } ;
    
    // cascade
    for(CCNode *n in self.children) {
        [n updateLayout];
    }
}

- (tLayoutOrientation) layoutOrientation
{
    return kLayoutOrientationUnknown;
}

@end

@implementation CXVerticalContainer

- (tLayoutOrientation) layoutOrientation
{
    return kLayoutOrientationVertical;
}

- (id) init
{
    if (self = [super init]) {
        CCSprite *spr = [[[CCSprite alloc] initWithFile:@"debugSprite.png"] autorelease];
        spr.tag = 9088;
        spr.visible = FALSE;
        //[self addChild:[spr autorelease]];
    }
    return self;
}

@end

@implementation CXHorizontalContainer

- (tLayoutOrientation) layoutOrientation
{
    return kLayoutOrientationHorizontal;
}

- (id) init
{
    if (self = [super init]) {
        CCSprite *spr = [[[CCSprite alloc] initWithFile:@"debugSprite.png"] autorelease];
        spr.tag = 9088;
        spr.visible = FALSE;
        //[self addChild:spr];
    }
    return self;
}
@end
