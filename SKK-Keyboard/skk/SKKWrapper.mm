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
    SKKDictionaryKeyContainer keys;
    
    NSString* dict = [[NSBundle mainBundle] pathForResource:@"skk" ofType:@"jisyo"];
    std::string userdict([dict cStringUsingEncoding: NSUTF8StringEncoding]);
    
    SKKBackEnd::theInstance().Initialize(userdict, keys);
    
    NSString* rule = [[NSBundle mainBundle] pathForResource:@"kana-rule" ofType:@"conf"];
    SKKRomanKanaConverter::theInstance().Initialize([rule cStringUsingEncoding:NSUTF8StringEncoding]);
    
    map = new SKKKeymap();
    
    NSString* k = [[NSBundle mainBundle] pathForResource:@"keymap" ofType: @"conf"];
    [self keymap]->Initialize([k cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
    param = new MacInputSessionParameter(delegate);
    session = new SKKInputSession([self param]);
    return self;
}

- (bool)handle: (int)charcode keycode:(int)keycode mods:(int)mods
{
    SKKEvent event = [self keymap]->Fetch(charcode, 0, 0);
    return [self inputSession]->HandleEvent(event);
}

@end