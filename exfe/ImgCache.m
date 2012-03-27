//
//  ImgCache.m
//  exfe
//
//  Created by 霍 炬 on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImgCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ImgCache

static id sharedManager = nil;
static NSMutableDictionary *imgs;

+ (id)sharedManager {
    @synchronized(self)    
    {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
            imgs = [[NSMutableDictionary alloc]initWithCapacity:50];
            
        }
    }
    return sharedManager;
}
+ (NSString*) CachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images"];
    BOOL writedir=[[NSFileManager defaultManager] isWritableFileAtPath:path];
    if(writedir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *) md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}
+ (NSString *) getImgName:(NSString *)url
{
    NSString *md5key=[ImgCache md5:url];
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
	NSFileManager *fileManager=[NSFileManager defaultManager];
    
    BOOL success=[fileManager fileExistsAtPath:cachefilename];
    if(!success)
    {
        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [data writeToFile:cachefilename atomically:YES];
        
    }
    
    return md5key;
}
- (UIImage*) getImgFrom:(NSString*)url
{
    NSString *md5key=[ImgCache md5:url];
    UIImage* imgfromdict=(UIImage*)[imgs objectForKey:md5key];
    if(imgfromdict!=nil)
        return imgfromdict;
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
    UIImage *img=[UIImage imageWithContentsOfFile:cachefilename];
    if(img==nil)
    {
        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        img = [UIImage imageWithData:data];
        [data writeToFile:cachefilename atomically:YES];
    }
    
    if(img!=nil)
        [imgs setObject:img forKey:md5key];
    else
        [imgs setObject:[NSNull null] forKey:md5key];
    return img;
    
}

+ (NSString *) getImgUrl:(NSString*)imgName
{
    if([[imgName substringWithRange:NSMakeRange(0,5)] isEqualToString:@"http:"])
        return imgName;
    
    if([imgName isEqualToString:@"default.png"])
        return [NSString stringWithFormat:@"http://img.exfe.com/web/80_80_%@",imgName];
    else
        return [NSString stringWithFormat:@"http://img.exfe.com/%@/%@/80_80_%@",[imgName substringWithRange:NSMakeRange(0, 1)],[imgName substringWithRange:NSMakeRange(1, 2)],imgName];
}
@end
