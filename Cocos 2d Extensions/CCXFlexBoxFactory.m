//
//  CCXFlexBoxFactory.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "CCXFlexBoxFactory.h"
#import "CCXFlexBoxFactory+items.h"

@interface CCXFlexBoxFactory ()
{
    NSMutableArray  *_flexStack;
    NSMutableArray  *_nodeStack;
    CCNode          *_node;
}
@end

@implementation CCXFlexBoxFactory

- (void) dealloc
{
    [_flexStack release];
    [_nodeStack release];
    [super dealloc];
}

- (id) initWithUrl:(NSURL*)url node:(CCNode*)node
{
    if (self = [self init]) {
        
        _flexStack = [[NSMutableArray alloc]init];
        _nodeStack = [[NSMutableArray alloc]init];
        _node = node;
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        parser.delegate = self;
        [parser parse];
        [parser release];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSString *baseClass = elementName;
    
    if ([baseClass isEqualToString:@"layout"]) {
        [self setLayoutAttributes:attributeDict];
        return;
    }
    
    if ([baseClass isEqualToString:@"flex"]) {
        baseClass = @"CCXFlexBox";
    }

    bool isFlexItem = false;
    if ([baseClass isEqualToString:@"CCXFlexBox"]) {
        isFlexItem = true;
    }
    
    NSString *selName = [NSString stringWithFormat:@"create%@WithAttributes:", baseClass];
    SEL sel = NSSelectorFromString(selName);
    if (![self respondsToSelector:sel]) {
        NSLog(@"%@ selector is missing", selName);
        return;
    }
    
    id obj = [self performSelector:sel withObject:attributeDict];
    
    CCXFlexBox *topFlex = [_flexStack lastObject];
    if (topFlex == nil)
        topFlex = self;
    
    if (isFlexItem) {
        [topFlex addItem:obj];
        [_flexStack addObject:obj];
        return;
    }
    
    if ([obj isKindOfClass:[CCNode class]]) {
        
        CCNode *parent = [_nodeStack lastObject];
    
        if (parent == nil) {
            CCXFlexBoxNodeContainer *container = [[[CCXFlexBoxNodeContainer alloc]initWithNode:obj] autorelease];
            [container setLayoutAttributes:attributeDict];
            [container setContainerAttributes:attributeDict];
            [topFlex addItem:container];
            parent = _node;
        }
        
        [_nodeStack addObject:obj];
        
        NSInteger parentTag = 0;
        NSString *val = [attributeDict valueForKey:@"parent"];
        if (val != nil) {
            parentTag = [val integerValue];
            parent = [_node getChildByTag:parentTag];
        }
        
        if (parent == nil)
            parent = _node;

        [parent addChild:obj];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *baseClass = elementName;
    if ([baseClass isEqualToString:@"flex"]) {
        baseClass = @"CCXFlexBox";
    }
    
    if ([baseClass isEqualToString:@"CCXFlexBox"]) {
        [_flexStack removeLastObject];
    }
    
    NSString *selName = [NSString stringWithFormat:@"create%@WithAttributes:", baseClass];
    SEL sel = NSSelectorFromString(selName);
    if ([self respondsToSelector:sel]) {
        [_nodeStack removeLastObject];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    CCNode *topNode = [_nodeStack lastObject];
    if (topNode != nil) {
        if ([topNode respondsToSelector:@selector(setString:)]) {
            [topNode setString:string];
        }
    }

}

@end
