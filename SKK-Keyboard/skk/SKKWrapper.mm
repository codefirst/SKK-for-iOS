//
//  SKKWrapper.m
//  SKK
//
//  Created by mzp on 2014/09/21.
//
//

#include "SKKKeymap.h"
#include "SKKInputSession.h"
#include "SKKKeymap.h"
#include "SKKRomanKanaConverter.h"
#include "SKKBackEnd.h"
#include "MacInputSessionParameter.h"
#import "SKKWrapper.h"
#include "SKKDictionaryFactory.h"
#include "SKKCommonDictionary.h"

@implementation SKKWrapper

- (SKKInputSession*)inputSession
{
    return (SKKInputSession*)session;
}

- (SKKKeymap*)keymap
{
    return (SKKKeymap*)map;
}

- (MacInputSessionParameter*)param
{
    return (MacInputSessionParameter*)param;
}

- (id)init:(id<WrapperParameter>) delegate
{
    // initialize Dict
    SKKRegisterFactoryMethod<SKKCommonDictionaryUTF8>(0);
    
    // register default dict
    SKKDictionaryKeyContainer keys;
    NSString* dict = [[NSBundle mainBundle] pathForResource:@"skk" ofType:@"jisyo"];
    keys.push_back(std::pair<int,std::string>(0, [dict cStringUsingEncoding:NSUTF8StringEncoding]));

    // create user dict(if need)
    NSString* userDict = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/skk.jisyo"];
    if(![[NSFileManager defaultManager] fileExistsAtPath: userDict]){
        [[NSFileManager defaultManager] createFileAtPath:userDict contents:nil attributes:nil];
    }
    NSLog(@"%@\n", userDict);
    
    // initialize backend
    std::string userdict([userDict cStringUsingEncoding: NSUTF8StringEncoding]);
    SKKBackEnd::theInstance().Initialize(userdict, keys);
    
    NSString* rule = [[NSBundle mainBundle] pathForResource:@"kana-rule" ofType:@"conf"];
    SKKRomanKanaConverter::theInstance().Initialize([rule cStringUsingEncoding:NSUTF8StringEncoding]);
    
    map = new SKKKeymap();
    
    NSString* k = [[NSBundle mainBundle] pathForResource:@"keymap" ofType: @"conf"];
    [self keymap]->Initialize([k cStringUsingEncoding:NSUTF8StringEncoding]);
    
    param = new MacInputSessionParameter(delegate);
    
    session = new SKKInputSession([self param]);
    [self inputSession]->AddInputModeListener([self param]->Listener());
    return self;
}

- (bool)handle: (int)charcode keycode:(int)keycode mods:(int)mods
{
    SKKEvent event = [self keymap]->Fetch(charcode, 0, 0);
    return [self inputSession]->HandleEvent(event);
}

- (void)toggleMode
{
    switch([self param]->CurrentMode()) {
        case InputMode::AsciiMode:
            [self changeMode: InputMode::HirakanaMode];
            break;
        case InputMode::HirakanaMode:
            [self changeMode: InputMode::KatakanaMode];
            break;
        case InputMode::KatakanaMode:
            [self changeMode: InputMode::Jis0201KanaMode];
            break;
        case InputMode::Jis0201KanaMode:
            [self changeMode: InputMode::Jis0208LatinMode];
            break;
        case InputMode::Jis0208LatinMode:
            [self changeMode: InputMode::AsciiMode];
            break;
        case InputMode:: NullMode:
            [self changeMode: InputMode::AsciiMode];
            break;
    }
}

- (void)changeMode: (InputMode)mode {
    SKKInputMode m = SKKInputMode::InvalidInputMode;
    SKKEvent event;
    switch(mode){
        case InputMode::AsciiMode:
            event.id = SKK_ASCII_MODE;
            m = SKKInputMode::AsciiInputMode;
            break;
        case InputMode::HirakanaMode:
            event.id = SKK_HIRAKANA_MODE;
            m = SKKInputMode::HirakanaInputMode;
            break;
        case InputMode::KatakanaMode:
            event.id = SKK_KATAKANA_MODE;
            m = SKKInputMode::KatakanaInputMode;
            break;
        case InputMode::Jis0201KanaMode:
            event.id = SKK_JISX0201KANA_MODE;
            m = SKKInputMode::Jisx0201KanaInputMode;
            break;
        case InputMode::Jis0208LatinMode:
            event.id = SKK_JISX0208LATIN_MODE;
            m = SKKInputMode::Jisx0208LatinInputMode;
            break;
        case InputMode:: NullMode:
            event.id = SKK_ASCII_MODE;
            m = SKKInputMode::InvalidInputMode;
            break;
    }
    [self inputSession]->HandleEvent(event);
    [self param]->Listener()->SelectInputMode(m);
}


@end