//
//  FlexTest.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "FlexTest.h"
#import "CCXFlexBox.h"
#import "CCXFlexBoxFactory.h"
#import "cocos2d.h"

@interface FlexTest ()
{
    CCXFlexBox *root;
    CGSize lastSize;
}
@end

@implementation FlexTest

- (void) dealloc
{
    [root release];
    [super dealloc];
}

- (id) init
{
    if (self = [super init]) {
        
        CCMenu *menu = [[[CCMenu alloc]init]autorelease];
        [self addChild:menu];
        menu.tag= 1;
        menu.position = ccp(0,0);

        NSURL *url = [[NSBundle mainBundle] URLForResource:@"holyGrail" withExtension:@"xml"];
        root = [[CCXFlexBoxFactory alloc]initWithUrl:url node:self];
        
        CCLabelBMFont *l = (CCLabelBMFont*)[self getChildByTag:123];
        l.string = @"??";

        CCMenuItem *menuItem = (CCMenuItem*)[menu getChildByTag:101];
        [menuItem setBlock:^(id sender) {
            root.direction = kFlexBoxDirectionRow;
            [root scheduleLayout];
        }];

        menuItem = (CCMenuItem*)[menu getChildByTag:102];
        [menuItem setBlock:^(id sender) {
            root.direction = kFlexBoxDirectionColumn;
            [root scheduleLayout];
        }];
        
        //[root debugLog];
        [self scheduleUpdate];
    }
    return self;
}

- (void) update:(ccTime)delta
{
    CGSize sz = [CCDirector sharedDirector].winSize;
    if (!CGSizeEqualToSize(lastSize, sz)) {
        lastSize = sz;
        CGRect f = root.frame;
        f.size = sz;
        //f.origin = ccp(100,100);
        //f.size.width = sz.width/2;
        //f.size.height = sz.height/2;
        root.frame = f;
        [root layout];
    }
}

- (void) draw
{
    [root debugDraw];
    [super draw];
}

@end
