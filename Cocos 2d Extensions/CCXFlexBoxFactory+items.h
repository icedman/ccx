//
//  CCXFlexBoxFactory+items.h
//  Cocos 2d Extensions
//
//  Created by Marvin Sanchez on 5/27/13.
//  Copyright (c) 2013 Marvin Sanchez. All rights reserved.
//

#import "CCXFlexBoxFactory.h"

@interface CCXFlexBoxFactory (items)
@end

@interface CCXFlexBox (items)
- (void) setLayoutAttributes:(NSDictionary*) attributes;
@end

@interface CCXFlexBoxNodeContainer (items)
- (void) setContainerAttributes:(NSDictionary*) attributes;
@end
