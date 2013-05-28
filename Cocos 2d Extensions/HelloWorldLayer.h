//
//  HelloWorldLayer.h
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/10/13.
//  Copyright Marvin Sanchez 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCXScrollLayer.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCXScrollLayer
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
