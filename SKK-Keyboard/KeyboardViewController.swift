//
//  KeyboardViewController.swift
//  SKK for iOS
//
//  Created by mzp on 2014/09/18.
//  Copyright (c) 2014年 codefirst. All rights reserved.
//

import UIKit

class KeyboardViewController: ImitationKeyboardViewController, WrapperParameter {
    enum Keycode : Int {
        case Switch = 1,
        Alphabet,
        Mode,
        Shift,
        BackSpace,
        Enter
    }
    
    var session : SKKWrapper = SKKWrapper()
    
    let compose : UILabel = UILabel()
    
    let candidateScrollView : UIScrollView = UIScrollView()
    
    var mods : Int = 0
    
    let Keyboards : [[(String, Keycode)]] = [[
            ("q",.Alphabet),
            ("w",.Alphabet),
            ("e",.Alphabet),
            ("r",.Alphabet),
            ("t",.Alphabet),
            ("y",.Alphabet),
            ("u",.Alphabet),
            ("i",.Alphabet),
            ("o",.Alphabet),
            ("p",.Alphabet)
        ],
        [
            ("a", .Alphabet),
            ("s", .Alphabet),
            ("d", .Alphabet),
            ("f", .Alphabet),
            ("g", .Alphabet),
            ("h", .Alphabet),
            ("j", .Alphabet),
            ("k", .Alphabet),
            ("l", .Alphabet),
            ("v", .Enter)
        ],
        [
            ("^", .Shift),
            ("z", .Alphabet),
            ("x", .Alphabet),
            ("c", .Alphabet),
            ("v", .Alphabet),
            ("b", .Alphabet),
            ("n", .Alphabet),
            ("m", .Alphabet),
            ("<", .BackSpace)
        ],
        [
            (".", .Switch),
            ("あ", .Mode),
            (" ", .Alphabet)
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // compose
        compose.text = "welcome to SKK for iOS"
        compose.frame = CGRect(x: 10, y:0 , width: 300, height: 40)
        infoView.addSubview(compose)
        
        // candidate
        let screenWidth = UIScreen.mainScreen().bounds.width
        candidateScrollView.frame = CGRect(x: 0, y:0, width: screenWidth, height: 40)

        session = SKKWrapper(self)
    }
    
    func handle(charcode: CChar){
        let b = session.handle(Int32(charcode), keycode: 0, mods: Int32(mods))
        if(!b) {
            if(charcode != 0x08){
                let input : UIKeyInput? = (self.textDocumentProxy as UIKeyInput)

                switch input {
                case .None:
                    ()
                case .Some(let p):
                    p.insertText(String.fromCString([charcode])!)
                }

            }else{
                (self.textDocumentProxy as UIKeyInput).deleteBackward()
            }
        }
        mods = 0
    }
    
    func insertText(text: String!) {
        NSLog("%@\n", text)
        (self.textDocumentProxy as UITextDocumentProxy).insertText(text)
    }
    
    func composeText(text: String!) {
        compose.text = text
    }
    
    func updateCandidate(xs: NSMutableArray!) {
        compose.removeFromSuperview()
        candidateScrollView.setContentOffset(CGPointMake(0,0), animated: false)
        infoView.addSubview(candidateScrollView)
        
        for x in candidateScrollView.subviews {
            x.removeFromSuperview()
        }
        
        let font = UIFont.systemFontOfSize(22)
        var pos : CGFloat = 5
        for (i, x) in enumerate(xs) {
            let s = (x as NSString)
            let button  = UIButton.buttonWithType(.System) as UIButton
            let size = s.sizeWithAttributes([NSFontAttributeName: font])
            button.setTitle(s, forState: .Normal)
            button.titleLabel?.font = font
            button.tag = i + 0x21
            button.frame = CGRect(x: pos, y: 5, width: size.width, height: size.height)
            button.addTarget(self, action: "handleCandidate:", forControlEvents: UIControlEvents.TouchUpInside)
            
            candidateScrollView.addSubview(button)
            
            pos += size.width + 5
        }
        candidateScrollView.contentSize = CGSize(width: pos, height: 40)
        return;
    }
    
    func handleCandidate(sender : UIButton) {
        session.handle(Int32(sender.tag), keycode: 0, mods: 0)
        candidateScrollView.removeFromSuperview()
        infoView.addSubview(compose)
    }
    
    func selectInputMode(mode : InputMode) {
        var icon = ""
        switch mode {
        case .HirakanaMode:
            icon = "あ"
        case .KatakanaMode:
            icon = "ア"
        case .AsciiMode:
            icon = "A"
        case .Jis0201KanaMode:
            icon = "ｶﾅ"
        case .Jis0208LatinMode:
            icon = "英"
        case .NullMode:
            icon = "-"
        }
        for (model, key) in self.layout.modelToView {
            if(model.type == Key.KeyType.InputModeChange) {
                key.text = icon
            }
        }
    }
    
    override func keyPressed(sender: KeyboardKey) {
        UIDevice.currentDevice().playInputClick()
        let model : Key? = self.layout.keyForView(sender)
        switch model?.outputText {
        case .None:
            ()
        case .Some(let text):
            var t : String = text
            if(self.shiftState == ShiftState.Disabled) {
                t = t.lowercaseString
            }
            let n  = (t as NSString).characterAtIndex(0)
            handle(CChar(n))
        }
        if self.shiftState == .Enabled {
            self.shiftState = .Disabled
        }

    }
    
    override func backspacePressed() {
        handle(0x08)
    }
    
    func inputModeChangeTapped() {
        session.toggleMode()
    }
}
