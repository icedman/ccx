//
//  CCXFlexBoxFactory+items.m
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "CCXFlexBoxFactory+items.h"

@implementation CCXFlexBox (items)

- (void) setLayoutAttributes:(NSDictionary*) attributes
{
    NSString *val;
    
    val = [attributes valueForKey:@"tag"];
    if (val != nil) {
        self.tag = [val intValue];
    }
    
    val = [attributes valueForKey:@"direction"];
    if (val != nil) {
        if ([val isEqualToString:@"column"])
            self.direction = kFlexBoxDirectionColumn;
        if ([val isEqualToString:@"row"])
            self.direction = kFlexBoxDirectionRow;
    }
    
    val = [attributes valueForKey:@"justify"];
    if (val != nil) {
        if ([val isEqualToString:@"start"])
            self.justify = kFlexBoxJustifyStart;
        if ([val isEqualToString:@"end"])
            self.justify = kFlexBoxJustifyEnd;
        if ([val isEqualToString:@"center"])
            self.justify = kFlexBoxJustifyCenter;
        if ([val isEqualToString:@"space-around"])
            self.justify = kFlexBoxJustifySpaceAround;
        if ([val isEqualToString:@"space-between"])
            self.justify = kFlexBoxJustifySpaceBetween;
    }
    
    val = [attributes valueForKey:@"align"];
    if (val != nil) {
        if ([val isEqualToString:@"start"])
            self.align = kFlexBoxAlignStart;
        if ([val isEqualToString:@"end"])
            self.align = kFlexBoxAlignEnd;
        if ([val isEqualToString:@"center"])
            self.align = kFlexBoxAlignCenter;
        if ([val isEqualToString:@"stretch"])
            self.justify = kFlexBoxAlignStretch;
    }
    
    val = [attributes valueForKey:@"visibility"];
    if (val != nil) {
        self.visibility = kFlexBoxVisibilityShow;
        if ([val isEqualToString:@"hide"])
            self.visibility = kFlexBoxVisibilityHide;
        if ([val isEqualToString:@"collapse"])
            self.visibility = kFlexBoxVisibilityCollapse;
    }
    
    val = [attributes valueForKey:@"shrink"];
    if (val != nil) {
        self.shrink = [val intValue];
    }
    
    val = [attributes valueForKey:@"grow"];
    if (val != nil) {
        self.grow = [val intValue];
    }
    
    val = [attributes valueForKey:@"minWidth"];
    if (val != nil) {
        if ([val isEqualToString:@"auto"])
            self.minWidth = kFlexBoxAuto;
        else  if ([val isEqualToString:@"none"])
            self.minWidth = kFlexBoxNone;
        else
            self.minWidth = [val intValue];
    }
    
    val = [attributes valueForKey:@"minHeight"];
    if (val != nil) {
        if ([val isEqualToString:@"auto"])
            self.minHeight = kFlexBoxAuto;
        else  if ([val isEqualToString:@"none"])
            self.minHeight = kFlexBoxNone;
        else
            self.minHeight = [val intValue];
    }
    
    val = [attributes valueForKey:@"width"];
    if (val != nil) {
        CGRect f = self.frame;
        f.size.width = [val intValue];
        self.frame = f;
    }
    val = [attributes valueForKey:@"height"];
    if (val != nil) {
        CGRect f = self.frame;
        f.size.height = [val intValue];
        self.frame = f;
    }
}

@end

@implementation CCXFlexBoxNodeContainer (items)

- (void) setContainerAttributes:(NSDictionary*) attributes
{
    NSString *val;
    val = [attributes valueForKey:@"padding"];
    if (val != nil) {
        self.padding = [val intValue];
    }
    val = [attributes valueForKey:@"paddingTop"];
    if (val != nil) {
        self.paddingTop = [val intValue];
    }
    val = [attributes valueForKey:@"paddingBottom"];
    if (val != nil) {
        self.paddingBottom = [val intValue];
    }
    val = [attributes valueForKey:@"paddingLeft"];
    if (val != nil) {
        self.paddingLeft = [val intValue];
    }
    val = [attributes valueForKey:@"paddingRight"];
    if (val != nil) {
        self.paddingRight = [val intValue];
    }
}
@end

@interface CCNode (items)
@end

@implementation CCNode (items)

- (void) setNodeAttributes:(NSDictionary*) attributes
{
    NSString *val;
    val = [attributes valueForKey:@"tag"];
    if (val != nil) {
        self.tag = [val intValue];
    }
    
    val = [attributes valueForKey:@"x"];
    if (val != nil) {
        CGPoint p = self.position;
        p.x = [val floatValue];
        self.position = p;
    }
    
    val = [attributes valueForKey:@"y"];
    if (val != nil) {
        CGPoint p = self.position;
        p.y = [val floatValue];
        self.position = p;
    }
    
    val = [attributes valueForKey:@"width"];
    if (val != nil) {
        CGSize sz = self.contentSize;
        sz.width = [val floatValue];
        self.contentSize = sz;
    }

    val = [attributes valueForKey:@"height"];
    if (val != nil) {
        CGSize sz = self.contentSize;
        sz.height = [val floatValue];
        self.contentSize = sz;
    }
    
}
@end

@implementation CCXFlexBoxFactory (items)

- (id) createCCXFlexBoxWithAttributes:(NSDictionary*) attributes
{
    CCXFlexBox *res = [[[CCXFlexBox alloc]init] autorelease];
    [res setLayoutAttributes:attributes];
    return res;
}

- (id) createCCSpriteWithAttributes:(NSDictionary*) attributes
{
    NSString *file = [attributes valueForKey:@"file"];
    if (file == nil)
        return nil;
    CCSprite *res = [[[CCSprite alloc]initWithFile:file] autorelease];
    [res setNodeAttributes:attributes];
    return res;
}

- (id) createCCLabelBMFontWithAttributes:(NSDictionary*) attributes
{
    NSString *string = [attributes valueForKey:@"string"];
    if (string == nil)
        string = @"";
    NSString *fnt = [attributes valueForKey:@"font"];
    if (fnt == nil)
        return nil;
    CCLabelBMFont *res = [CCLabelBMFont labelWithString:string fntFile:fnt];
    [res setNodeAttributes:attributes];
    return res;
}

- (id) createCCMenuItemWithAttributes:(NSDictionary*) attributes
{
    CCMenuItem *res = [CCMenuItem itemWithBlock:^(id sender) {
        NSLog(@"%@ called", sender);
    }];
    res.contentSize = CGSizeMake(40,40);
    [res setNodeAttributes:attributes];
    return res;
}

@end
