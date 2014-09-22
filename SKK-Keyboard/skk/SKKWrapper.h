//
//  SKKWrapper.h
//  SKK
//
//  Created by mzp on 2014/09/21.
//
//

#ifndef SKK_SKKWrapper_h
#define SKK_SKKWrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WrapperParameter<NSObject>
- (void)insertText: (NSString*)text;
- (void)composeText: (NSString*)text;
@end

@interface SKKWrapper : NSObject {
    void* map;
    void* param;
    void* session;
}

- (id)init: (id<WrapperParameter>)proxy;
- (bool)handle: (int)charcode keycode:(int)keycode mods:(int)mods;
@end

#endif
