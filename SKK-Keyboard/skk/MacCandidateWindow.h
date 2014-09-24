#ifndef MacCandidateWindow_h
#define MacCandidateWindow_h

#include "SKKCandidateWindow.h"
#import "SKKWrapper.h"

class MacCandidateWindow : public SKKCandidateWindow {
    id<WrapperParameter> delegate_;
    
    virtual void SKKWidgetShow();
    virtual void SKKWidgetHide();
public:
    MacCandidateWindow(id<WrapperParameter> delegate);
    virtual void Setup(SKKCandidateIterator begin, SKKCandidateIterator end, std::vector<int>& pages);
    virtual void Update(SKKCandidateIterator begin, SKKCandidateIterator end, int cursor, int page_pos, int page_max);
    virtual int LabelIndex(char label);
};

#endif
