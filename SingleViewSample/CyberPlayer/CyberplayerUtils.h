//
//  CyberplayerUtils.h
//  cyberplayer
//
//  Created by zengfanping on 6/17/13.
//  Copyright (c) 2013 mco-multimedia. All rights reserved.
//

#import <Foundation/Foundation.h>
// 设置dictionary的键值对
#define DICTIONARY_SET_OBJECT_FOR_KEY(dictionay,object,key)			\
do{																	\
if ((object) != nil && (key) != nil)							\
{																\
[(dictionay) setObject:(object) forKey:(key)];				\
}																\
}while(0)
#define DICT_ADD DICTIONARY_SET_OBJECT_FOR_KEY
// RELEASE_SET_NIL
#define RELEASE_SET_NIL(aobj)							\
do{[aobj release]; aobj = nil;}while(0)

@interface CyberplayerUtils : NSObject
+ (NSString *) platform;
+ (NSString *) platformString;
+ (NSString *) deviceFamily;
+ (NSString *) getMyIPAddress;
+ (NSString *) localIPAddress;
@end
