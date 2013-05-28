//
//  LayoutTest.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/22/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "LayoutTest.h"
#import "CCXBoxLayout.h"

@interface LayoutTest ()
{
    CCXBoxLayoutItem *root;
}
@end

@implementation LayoutTest

- (void) dealloc
{
    [root release];
    [super dealloc];
}

-(id) init
{
	if( (self=[super init]) ) {
        root = [[CCXHorizontalBoxItem alloc] init];
        
        root.frame = CGRectMake(0,0,300,250);
        root.justify = kBoxLayoutJustifySpaceBetween;
        root.align = kBoxLayoutAlignCenter;
        
        CCXBoxLayoutItem *toolbar = [[CCXHorizontalBoxItem alloc] init];
        toolbar.frame = CGRectMake(0,0,250,60);
        toolbar.justify = kBoxLayoutJustifySpaceAround;
        toolbar.align = kBoxLayoutAlignCenter;
        
        //toolbar.visibility = kBoxLayoutVisibilityHide;
        
        CCNode *toolbarNodes = [[[CCNode alloc]init] autorelease];
        [self addChild:toolbarNodes];
        
        toolbar.node = toolbarNodes;
        
        for(int i=0;i<3;i++) {
            CCSprite *sprite = [[CCSprite alloc]initWithFile:@"debugSprite.png"];
            [toolbarNodes addChild: [sprite autorelease]];
            
            CCXBoxLayoutItem *box = [[CCXBoxLayoutItem alloc]initWithNode:sprite];
            box.frame = CGRectMake(20*i,20*i,50 - (i*10),50);
            [toolbar addItem:box];
        }
        
        for(int i=0;i<3;i++) {  
            CCSprite *sprite = [[CCSprite alloc]initWithFile:@"debugSprite.png"];
            [self addChild: [sprite autorelease]];
            
            CCXBoxLayoutItem *box = [[CCXBoxLayoutItem alloc]initWithNode:sprite];
            box.frame = CGRectMake(20*i,20*i,50 - (i*10),50);
            [root addItem:box];
            
            if (i == 1)
                [root addItem:toolbar];
        }
        
        [root layout];
        [self scheduleUpdate];
    }
    
    return self;
}

- (void) draw
{
    [root debugDraw];
}

- (void) update:(ccTime)df
{
    CGRect r;
    r.origin = CGPointZero;
    r.size = [[CCDirector sharedDirector]winSize];
    if (!CGRectEqualToRect(r, root.frame)) {
        root.frame = r;
        [root layout];
    }
}

@end
