//
//  MacInputSessionParameter.h
//  SKK
//
//  Created by mzp on 2014/09/21.
//
//

#ifndef SKK_MacInputSessionParameter_h
#define SKK_MacInputSessionParameter_h

#import <UIKit/UIKit.h>
#include "SKKInputSessionParameter.h"
#include "MockConfig.h"
#include "MockFrontEnd.h"
#include "MockMessenger.h"
#include "MockClipboard.h"
#include "MacCandidateWindow.h"
#include "MockAnnotator.h"
#include "MockDynamicCompletor.h"
#include "MacFrontEnd.h"

class MacInputSessionParameter : public SKKInputSessionParameter {
    MockConfig config_;
    MacFrontEnd* frontend_;
    MockMessenger messenger_;
    MockClipboard clipboard_;
    MacCandidateWindow* candidate_;
    MockAnnotator annotator_;
    MockDynamicCompletor completor_;
    
public:
    MacInputSessionParameter(id<AquaSKKSessionDelegate> delegate) :
        frontend_(new MacFrontEnd(delegate)),
        candidate_(new MacCandidateWindow(delegate))
    {}
    
    virtual SKKConfig* Config() { return &config_; }
    virtual SKKFrontEnd* FrontEnd() { return frontend_; }
    virtual SKKMessenger* Messenger() { return &messenger_; }
    virtual SKKClipboard* Clipboard() { return &clipboard_; }
    virtual SKKCandidateWindow* CandidateWindow() { return candidate_; }
    virtual SKKAnnotator* Annotator() { return &annotator_; }
    virtual SKKDynamicCompletor* DynamicCompletor() { return &completor_; }
    virtual SKKInputModeListener* Listener(){ return frontend_; }
    virtual InputMode CurrentMode() const { return frontend_->CurrentMode(); }
};

#endif
