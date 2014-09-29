/* -*- ObjC -*-

  MacOS X implementation of the SKK input method.

  Copyright (C) 2008 Tomotaka SUWA <t.suwa@mac.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#include <iostream>
#include "MacFrontEnd.h"
#include "utf8util.h"
#include "SKKInputMode.h"

MacFrontEnd::MacFrontEnd(id<AquaSKKSessionDelegate> delegate) : delegate_(delegate), currentMode_(HirakanaMode) {}

void MacFrontEnd::InsertString(const std::string& str) {
    NSString* string = @"";

    if(!str.empty()) {
        string = [NSString stringWithUTF8String:str.c_str()];
    }

    [delegate_ insertText:string];
}

void MacFrontEnd::ComposeString(const std::string& str, int cursorOffset) {
    [delegate_ composeText: [NSString stringWithUTF8String:str.c_str()]];
}

void MacFrontEnd::ComposeString(const std::string& str, int candidateStart, int candidateLength) {
    [delegate_ composeText: [NSString stringWithUTF8String:str.c_str()]];
}

std::string MacFrontEnd::SelectedString() {
    return "";
}

void MacFrontEnd::SelectInputMode(SKKInputMode mode) {
    InputMode m = NullMode;
    switch(mode) {
        case HirakanaInputMode:
            m = InputMode::HirakanaMode;
            break;
        case KatakanaInputMode:
            m = InputMode::KatakanaMode;
            break;
        case Jisx0201KanaInputMode:
            m = InputMode::Jis0201KanaMode;
            break;
        case AsciiInputMode:
            m = InputMode::AsciiMode;
            break;
        case Jisx0208LatinInputMode:
            m = InputMode::Jis0208LatinMode;
            break;
        default:
            NSLog(@"Unknown mode: %d\n", mode);
    }
    [delegate_ selectInputMode: m];
    currentMode_ = m;
    
}

