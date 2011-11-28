//
//  ImgCache.h
//  exfe
//
//  Created by 霍 炬 on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSMutableDictionary *imgs;

@interface ImgCache : NSObject {
    NSString *cachepath;    
}


+ (id)sharedManager;
+ (NSString*) CachePath;
+ (NSString *) md5:(NSString *)str;
+ (NSString *) getImgName:(NSString *)url;
- (UIImage*) getImgFrom:(NSString*)url;
+ (NSString *) getImgUrl:(NSString*)imgName;
@end
