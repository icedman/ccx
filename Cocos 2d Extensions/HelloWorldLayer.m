//
//  HelloWorldLayer.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/10/13.
//  Copyright Marvin Sanchez 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCLabelBMFont+Format.h"
#import "CCNode+Layout.h"
#import "LayoutTest.h"
#import "FlexTest.h"

#define EDGE_CONSTRAINT 0.25

@interface HelloWorldLayer ()
{
    CCNode *layout;
    CGPoint _scrollTopPosition;
    CGPoint _scrollBottomPosition;
}
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [FlexTest node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
        
        layout = [[CXVerticalContainer alloc] init];
        [self addChild:[layout autorelease]];
		
		// create and initialize a Label
        for(int i=0;i<100;i++) {
            
            //CCNode *n = [CCNode node];
            //n.contentSize = CGSizeMake(200,80);
            //n.tag = i;
            //[layout addChild:n];
            
            CCLabelBMFont *label = [CCLabelBMFont labelWithHTML:[NSString stringWithFormat:@"<wave><color value='#f0f' valueTo='#ff0'><rotate value='10'>%d hello world</rotate></color></wave>", i] fntFile:@"konqa32.fnt"];
            [self addChild: label];
            label.tag = i;
            
            [layout addItem:label];
        }
        
        CGSize winSize = [[CCDirector sharedDirector]winSize];
        layout.contentSize = winSize;
        //layout.position = ccp(winSize.width/2, 0);
        
        [self updateLayout];
        //[layout walkSceneGraph:32];
        self.keyboardEnabled = YES;
        
        /*
        CCSprite *spr = [[CCSprite alloc] initWithFile:@"debugSprite.png"];
        spr.tag = 456;
        spr.scaleX = winSize.width / 32;
        spr.scaleY = winSize.height / 32;
        [self addChild:[spr autorelease]];
         */

        
	}
	return self;
}

- (void) dealloc
{
    NSLog(@"dealloc Hello");
	[super dealloc];
}

-(BOOL) ccKeyUp:(NSEvent*)event
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer node]];
    return YES;
}

-(BOOL) ccKeyDown:(NSEvent*)event
{
    return YES;
}

- (void) updateLayout
{    
    [super updateLayout];
    
    int h = 0;
    for(CCNode *item in layout.children) {
        h += item.contentSize.height;
    }
    
    CGSize sz = self.contentSize;
    sz.height = h;
    self.contentSize = sz;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    // scroll to top
    CGPoint pos = layout.position;
    pos.y = winSize.height - h/2;
    layout.position = pos;
    
    CGPoint p = self.scrollPosition;
    p.y = -layout.position.y;
    self.scrollPosition = p;
    
    _scrollTopPosition = p;
    
    p.y -= h - winSize.height;
    _scrollBottomPosition = p;
}

- (void) onScrollUpdate
{
    CGPoint pos = layout.position;
    pos.y = -self.scrollPosition.y;
    layout.position = pos;
}

- (void) onTouchBegan
{
}

- (void) onTouchEnded
{
    CCNode *touched = [self getTouchedItemInContainer:layout];
    if (touched != nil) {
        NSLog(@"%d", (int)touched.tag);
        if (touched.tag == 0) {

        }
    }
}


- (CCNode*) getTouchedItemInContainer:(CCNode*)container
{
    CGPoint p = self.pressPosition;
    p.x -= container.position.x + self.position.x;
    p.y -= container.position.y + self.position.y;
    for(CCNode *item in container.children) {
        CGRect r;
        r.origin = item.position;
        r.origin.x -= item.contentSize.width/2;
        r.origin.y -= item.contentSize.height/2;
        r.size = item.contentSize;
        if (CGRectContainsPoint(r, p)) {
            return item;
        }
    }
    
    return nil;
}


- (void) update:(ccTime)dt
{
    [super update:dt];
    
    if ([self isScrolling])
        return;
    
    if (-layout.position.y > _scrollTopPosition.y) {
        Float32 diff = _scrollTopPosition.y - (-layout.position.y);
        diff *= EDGE_CONSTRAINT;
        CGPoint p = layout.position;
        p.y -= diff;
        layout.position = p;
        CGPoint pos = self.scrollPosition;
        pos.y = -layout.position.y;
        self.scrollPosition = pos;
    }
    
    if (-layout.position.y < _scrollBottomPosition.y) {
        Float32 diff = _scrollBottomPosition.y - (-layout.position.y);
        diff *= EDGE_CONSTRAINT;
        CGPoint p = layout.position;
        p.y -= diff;
        layout.position = p;
        
        CGPoint pos = self.scrollPosition;
        pos.y = -layout.position.y;
        self.scrollPosition = pos;
    }
}

@end
