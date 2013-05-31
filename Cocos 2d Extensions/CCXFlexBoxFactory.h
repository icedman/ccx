//
//  CCXFlexBoxFactory.h
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "CCXFlexBox.h"

@interface CCXFlexBoxFactory : CCXFlexBox <NSXMLParserDelegate>

- (id) initWithUrl:(NSURL*)url node:(CCNode*)node;
- (void) loadUrl:(NSURL*)url node:(CCNode*)node;

@end


