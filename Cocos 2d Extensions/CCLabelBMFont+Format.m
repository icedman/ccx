//
//  CCLabelBMFont+Format.m
//  Cocos2d Extensions
//
//  Created by Marvin Sanchez on 5/6/13.
//
//

#import "CCLabelBMFont+Format.h"
#import "cocos2d.h"

@interface CXFormatRunColor : CXFormatRun
{
    ccColor4F _color;
}
@end

@implementation CXFormatRunColor


- (id) initWithStart:(UInt32)s length:(UInt32)l color:(ccColor4F) clr
{
    if (self = [self initWithStart:s length:l]) {
        _color = clr;
    }
    return self;
}

- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx
{
    spr.color = ccc3(255 * _color.r, 255 * _color.g, 255 * _color.b);
    spr.opacity = 255 * _color.a;
}

@end


@interface CXFormatRunColorGradient : CXFormatRun
{
    ccColor4F _color;
    ccColor4F _colorTo;
}
@end

@implementation CXFormatRunColorGradient


- (id) initWithStart:(UInt32)s length:(UInt32)l color:(ccColor4F) clr colorTo:(ccColor4F) clrTo
{
    if (self = [super initWithStart:s length:l]) {
        _color = clr;
        _colorTo = clrTo;
    }
    return self;
}

- (Float32) lerpFrom:(Float32) fStart to:(Float32) fEnd percent:(Float32) fPercent
{
    return fStart + ((fEnd - fStart) * fPercent);
}

- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx
{
    if (self.length == 0)
        return;
    
    Float32 p = (Float32)idx/self.length;
    Float32 r = [self lerpFrom:_color.r to:_colorTo.r percent: p];
    Float32 g = [self lerpFrom:_color.g to:_colorTo.g percent: p];
    Float32 b = [self lerpFrom:_color.b to:_colorTo.b percent: p];
    Float32 a = [self lerpFrom:_color.a to:_colorTo.a percent: p];
    spr.color = ccc3(255 * r, 255 * g, 255 * b);
    spr.opacity = 255 * a;
}

@end

@interface CXFormatRunRotate : CXFormatRun
{
    Float32 _rotation;
}
@end

@implementation CXFormatRunRotate

- (id) initWithStart:(UInt32)s length:(UInt32)l rotation:(Float32) rot
{
    if (self = [super initWithStart:s length:l]) {
        _rotation = rot;
    }
    return self;
}

- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx
{
    spr.rotation = _rotation;
}

@end

@interface CXFormatRunSkew : CXFormatRun
{
    Float32 _skew;
}
@end

@implementation CXFormatRunSkew


- (id) initWithStart:(UInt32)s length:(UInt32)l skew:(Float32) skew
{
    if (self = [super initWithStart:s length:l]) {
        _skew = skew;
    }
    return self;
}

- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx
{
    spr.skewX = _skew;
}

@end

@interface CXFormatRunWave : CXFormatRun
{
    Float32 _waveLength;
    Float32 _amplitude;
}
@end

@implementation CXFormatRunWave


- (id) initWithStart:(UInt32)s length:(UInt32)l waveLength:(Float32)w amplitude:(Float32)a
{
    if (self = [super initWithStart:s length:l]) {
        _waveLength = w;
        _amplitude = a;
    }
    return self;
}

- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx
{
    CGPoint p = spr.position;
    p.y += sin((Float32)(idx%(UInt32)(2*_waveLength))/_waveLength*3.19) * _amplitude;
    spr.position = p;
}

@end


@implementation CXFormatRun

@synthesize start   = _start;
@synthesize length  = _length;

- (id) initWithStart:(UInt32)s length:(UInt32)l
{
    if (self = [super init]) {
        _start = s;
        _length = l;
    }
    return self;
}

- (void) formatFontChar:(CCSprite*)spr withIndex:(UInt32)idx
{}


// factory

+ (CXFormatRun*) colorRunWithStart:(UInt32)s length:(UInt32)l color:(ccColor4F) clr
{
    CXFormatRun *obj = [[CXFormatRunColor alloc] initWithStart:s length:l color:clr];
    return [obj autorelease];
}

+ (CXFormatRun*) colorGradientRunWithStart:(UInt32)s length:(UInt32)l color:(ccColor4F) clr colorTo:(ccColor4F) clrTo
{
    CXFormatRun *obj = [[CXFormatRunColorGradient alloc] initWithStart:s length:l color:clr colorTo:clrTo];
    return [obj autorelease];
}

+ (CXFormatRun*) rotateRunWithStart:(UInt32)s length:(UInt32)l rotation:(Float32) rotation
{
    CXFormatRun *obj = [[CXFormatRunRotate alloc] initWithStart:s length:l rotation:rotation];
    return [obj autorelease];
}

+ (CXFormatRun*) skewRunWithStart:(UInt32)s length:(UInt32)l skew:(Float32) skew
{
    CXFormatRun *obj = [[CXFormatRunSkew alloc] initWithStart:s length:l skew:skew];
    return [obj autorelease];
}

+ (CXFormatRun*) waveRunWithStart:(UInt32)s length:(UInt32)l waveLength:(Float32)w amplitude:(Float32)a
{
    CXFormatRun *obj = [[CXFormatRunWave alloc] initWithStart:s length:l waveLength:w amplitude:a];
    return [obj autorelease];
}

@end


@interface CXXMLParserDelegate : NSObject <NSXMLParserDelegate>
{
    CCArray* _elementStack;
    UInt32   _characterIndex;
    UInt32   _charactersLength;
}

@property (readonly) NSMutableString* string;
@property (readonly) CCArray* formatRuns;
@end

@implementation CXXMLParserDelegate

@synthesize string       = _string;
@synthesize formatRuns   = _formatRuns;

- (void) dealloc
{
    for(CXFormatRun *r in _formatRuns) {
        [r release];
    }
    
    [_string release];
    [_formatRuns release];
    [_elementStack release];
    
    [super dealloc];
}

+ (ccColor4F) colorFromHexString:(NSString *)hexString
{
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return ccc4f(red,green,blue,alpha);
}

- (id) init
{
    if (self = [super init]) {
        _characterIndex = 0;
        _string = [[NSMutableString alloc]initWithCapacity:32];
        _formatRuns = [[CCArray alloc]initWithCapacity:32];
        _elementStack = [[CCArray alloc]initWithCapacity:32];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"br"]) {
        [_string appendString:@"\n"];
        return;
    }
    
    if ([elementName isEqualToString:@"color"]) {
        NSString *value = [attributeDict valueForKey:@"value"];
        NSString *valueTo = [attributeDict valueForKey:@"valueTo"];
        if (valueTo == nil)
            valueTo = value;
        ccColor4F clr = [CXXMLParserDelegate colorFromHexString: value];
        ccColor4F clrTo = [CXXMLParserDelegate colorFromHexString: valueTo];
        CXFormatRun *formatRun = [CXFormatRun colorGradientRunWithStart:_characterIndex length:0 color:clr colorTo:clrTo];
        [_elementStack addObject:formatRun];
        [_formatRuns addObject:[formatRun retain]];
        return;
    }
    
    if ([elementName isEqualToString:@"skew"]) {
        Float32 skew = 10.0;
        NSString *value = [attributeDict valueForKey:@"value"];
        if (value != nil)
            skew = [value floatValue];
        CXFormatRun *formatRun = [CXFormatRun skewRunWithStart:_characterIndex length:0 skew:skew];
        [_elementStack addObject:formatRun];
        [_formatRuns addObject:[formatRun retain]];
        return;
    }
    
    if ([elementName isEqualToString:@"rotate"]) {
        Float32 rot = 10.0;
        NSString *value = [attributeDict valueForKey:@"value"];
        if (value != nil)
            rot = [value floatValue];
        CXFormatRun *formatRun = [CXFormatRun rotateRunWithStart:_characterIndex length:0 rotation:rot];
        [_elementStack addObject:formatRun];
        [_formatRuns addObject:[formatRun retain]];
        return;
    }
    
    if ([elementName isEqualToString:@"wave"]) {
        Float32 w = 20.0;
        Float32 a = 10.0;
        NSString *waveLength = [attributeDict valueForKey:@"length"];
        NSString *amplitude = [attributeDict valueForKey:@"amplitude"];
        if (waveLength != nil)
            w = [waveLength floatValue];
        if (amplitude != nil)
            a = [amplitude floatValue];
        CXFormatRun *formatRun = [CXFormatRun waveRunWithStart:_characterIndex length:0 waveLength:w amplitude:a];
        [_elementStack addObject:formatRun];
        [_formatRuns addObject:[formatRun retain]];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *className;
    
    if ([elementName isEqualToString:@"color"]) {
        className = @"CXFormatRunColorGradient";
    }

    if ([elementName isEqualToString:@"skew"]) {
        className = @"CXFormatRunSkew";
    }

    if ([elementName isEqualToString:@"rotate"]) {
        className = @"CXFormatRunRotate";
    }

    if ([elementName isEqualToString:@"wave"]) {
        className = @"CXFormatRunWave";
    }
    
    CXFormatRun *formatRun = nil;
    for(int i=0; i < _elementStack.count; i++) {
        CXFormatRun *r = (CXFormatRun*)[_elementStack objectAtIndex:i];
        NSString *rClassName = [NSString stringWithFormat:@"%@", [r class]];
        if ([rClassName isEqualToString:className])
            formatRun = r;
    }
    
    if (formatRun != nil) {
        [_elementStack removeObject:formatRun];
        formatRun.length = _charactersLength;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_string appendString:string];
    _charactersLength = (UInt32)string.length;
    
    // new lines don't have sprites (exclude from count)
    NSInteger numberOfNewLines = [[string componentsSeparatedByCharactersInSet:
                         [NSCharacterSet newlineCharacterSet]] count];
    _charactersLength -= numberOfNewLines - 1;
    
    _characterIndex += _charactersLength;
}

@end

@implementation CCLabelBMFont (Format)

+ (id) labelWithUrl:(NSURL*)url fntFile:(NSString*)fnt
{
    CCLabelBMFont *label = [CCLabelBMFont alloc];
    [label initWithString:@"" fntFile:fnt];
    [label setURL:url];
    return [label autorelease];
    return [label autorelease];
}

+ (id) labelWithHTML:(NSString*)l fntFile:(NSString*)fnt
{
    CCLabelBMFont *label = [CCLabelBMFont alloc];
    [label initWithString:@"" fntFile:fnt];
    [label setHTML:l];
    return [label autorelease];
}

- (void) setURL:(NSURL*)url
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    CXXMLParserDelegate *delegate = [[CXXMLParserDelegate alloc] init];
    parser.delegate = delegate;
    
    [parser parse];
    
    [self setFormattedString:delegate.string formatRuns:delegate.formatRuns];
    
    [delegate release];
    [parser release];
}

- (void) setHTML:(NSString*)html
{
    NSData *data = [[NSString stringWithFormat:@"<XML>%@", html] dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    CXXMLParserDelegate *delegate = [[CXXMLParserDelegate alloc] init];
    parser.delegate = delegate;
    
    [parser parse];

    [self setFormattedString:delegate.string formatRuns:delegate.formatRuns];

    [delegate release];
    [parser release];
}

- (void) setFormattedString:(NSString*)s formatRuns:(CCArray*) formatRuns;
{
    [self setString:s];
    [self updateFormat:formatRuns];
}

- (void) updateFormat:(CCArray *)formatRuns
{
    // run formats
    for(CXFormatRun *f in formatRuns)
    {
        CCArray *fontChars = self.children;
        for(int i=f.start; i<f.start + f.length && i<fontChars.count; i++) {
            CCSprite *spr = (CCSprite*)[fontChars objectAtIndex:i];
            [f formatFontChar:spr withIndex:i-f.start];
        }
    }
}


@end
