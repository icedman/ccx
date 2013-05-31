//
//  CCLabelBMFont+Format.h
//  Cocos2d Extensions
//
//  Created by Marvin Sanchez on 5/6/13.
//
//

#import "CCLabelBMFont.h"
#import "cocos2d.h"

@interface CXFormatRun : NSObject

@property UInt32 start;
@property UInt32 length;

- (id) initWithStart:(UInt32)s length:(UInt32)l;
- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx;

+ (CXFormatRun*) colorRunWithStart:(UInt32)s length:(UInt32)l color:(ccColor4F) clr;
+ (CXFormatRun*) colorGradientRunWithStart:(UInt32)s length:(UInt32)l color:(ccColor4F) clr colorTo:(ccColor4F) clrTo;
+ (CXFormatRun*) skewRunWithStart:(UInt32)s length:(UInt32)l skew:(Float32) skew;
+ (CXFormatRun*) rotateRunWithStart:(UInt32)s length:(UInt32)l rotation:(Float32) rotation;
+ (CXFormatRun*) waveRunWithStart:(UInt32)s length:(UInt32)l waveLength:(Float32)w amplitude:(Float32)a;

@end

@interface CCLabelBMFont (Format)

+ (id) labelWithUrl:(NSURL*)url fntFile:(NSString*)fnt;
+ (id) labelWithHTML:(NSString*)l fntFile:(NSString*)fnt;
- (void) setFormattedString:(NSString*)s formatRuns:(CCArray*) formatRuns;
- (void) updateFormat:(CCArray*) formatRuns;
- (void) setHTML:(NSString*)html;
- (void) setURL:(NSURL*)url;

@end
