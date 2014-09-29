//
//  SKKWrapper.h
//  SKK
//
//  Created by mzp on 2014/09/21.
//
//

#ifndef AquaSKKSession_h
#define AquaSKKSession_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, InputMode) {
    AsciiMode,
    HirakanaMode,
    KatakanaMode,
    Jis0201KanaMode,
    Jis0208LatinMode,
    NullMode
};


@protocol AquaSKKSessionDelegate<NSObject>
- (void)insertText: (NSString*)text;
- (void)composeText: (NSString*)text;
- (void)updateCandidate: (NSMutableArray*)xs;
- (void)selectInputMode: (InputMode)mode;
@end

@interface AquaSKKSession : NSObject {
    void* map;
    void* param;
    void* session;
    int currentMode;
}

- (id)init;
- (void)setDelegate: (id<AquaSKKSessionDelegate>)delegate;
- (bool)handle: (int)charcode keycode:(int)keycode mods:(int)mods;
- (void)toggleMode;
- (void)changeMode: (InputMode)mode;
@end

#endif
