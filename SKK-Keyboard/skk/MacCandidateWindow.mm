#import "MacCandidateWindow.h"


MacCandidateWindow::MacCandidateWindow(id<WrapperParameter> delegate) : delegate_(delegate) {
}

void MacCandidateWindow::SKKWidgetShow() {
}

void MacCandidateWindow::SKKWidgetHide() {
}

void MacCandidateWindow::Setup(SKKCandidateIterator begin,
                       SKKCandidateIterator end,
                       std::vector<int>& pages) {
    pages.push_back((int)(end - begin));
}

void MacCandidateWindow::Update(SKKCandidateIterator begin,
                        SKKCandidateIterator end,
                        int cursor, int page_pos, int page_max) {
    NSMutableArray* xs = [[NSMutableArray alloc] init];
    for(SKKCandidateIterator it = begin; it != end; ++it) {
        NSString* s = [NSString stringWithUTF8String: (*it).Word().c_str()];
        [xs addObject: s];
    }
    [delegate_ updateCandidate:xs];
    return;
}

int MacCandidateWindow::LabelIndex(char label) {
    return label - 0x21;
}
