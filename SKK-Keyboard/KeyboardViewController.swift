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
    
    enum Modifier : Int {
        case Shift = 1, Ctrl = 2, Alt = 4, Meta = 8
    }
    
    var modeButton : UIButton! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // compose
        compose.text = "welcome to SKK for iOS"
        compose.frame = CGRect(x: 10, y:0 , width: 300, height: 40)
        view.addSubview(compose)
        
        // candidate
        let screenWidth = UIScreen.mainScreen().bounds.width
        candidateScrollView.frame = CGRect(x: 0, y:0, width: screenWidth, height: 40)
        
        // Keyboard layout
        for (i, cs) in enumerate(Keyboards) {
            for (j, (c,tag)) in enumerate(cs) {
                let button  = UIButton.buttonWithType(.System) as UIButton

                button.layer.borderColor = UIColor.blackColor().CGColor
                button.tag = tag.toRaw()
                button.addTarget(self, action: "handleKey:", forControlEvents: UIControlEvents.TouchUpInside)
                button.layer.borderWidth = 0.5
                button.layer.cornerRadius = 0.5
                button.setTitle(c as NSString, forState: .Normal)
                button.frame = CGRect(x: j * 31+5,y: i*43+40,width: 29,height: 41)
                view.addSubview(button)
                
                if(tag == .Mode) {
                    modeButton = button
                }
           }
        }
        
        session = SKKWrapper(self)
    }
    
    func handleKey(sender : UIButton!) {
        switch Keycode.fromRaw(sender.tag) {
        case .None:
            ()
        case .Some(let c):
            switch c {
            case .Switch:
                self.advanceToNextInputMode()
                mods = 0
            case .Alphabet:
                var key : String! = sender.titleForState(.Normal)
                if(mods & Modifier.Shift.toRaw() != 0) {
                    key = key.uppercaseString
                }
                let n  = (key as NSString).characterAtIndex(0)
                handle(CChar(n))
            case .Shift:
                mods = Modifier.Shift.toRaw()
            case .Enter:
                handle(0x0a)
                mods = 0
            case .BackSpace:
                handle(0x08)
            case .Mode:
                session.toggleMode()
                mods = 0
            default:
                ()
            }
        }
    }
    
    func handle(charcode: CChar){
        let b = session.handle(Int32(charcode), keycode: 0, mods: Int32(mods))
        if(!b) {
            if(charcode != 0x08){
                let input = (self.textDocumentProxy as UIKeyInput)
                input.insertText(String.fromCString([charcode])!)
            }else{
                (self.textDocumentProxy as UIKeyInput).deleteBackward()
            }
        }
        mods = 0
    }
    
    func insertText(text: String!) {
        (self.textDocumentProxy as UITextDocumentProxy).insertText(text)
    }
    
    func composeText(text: String!) {
        compose.text = text
    }
    
    func updateCandidate(xs: NSMutableArray!) {
        compose.removeFromSuperview()
        view.addSubview(candidateScrollView)
        
        for x in candidateScrollView.subviews {
            x.removeFromSuperview()
        }
        
        let font = UIFont.systemFontOfSize(24)
        var pos : CGFloat = 5
        for (i, x) in enumerate(xs) {
            let s = (x as NSString)
            let button  = UIButton.buttonWithType(.System) as UIButton
            let size = s.sizeWithAttributes([NSFontAttributeName: font])
            button.setTitle(s, forState: .Normal)
            button.titleLabel?.font = font
            button.tag = i + 0x20
            button.layer.borderWidth = 0.5
            button.frame = CGRect(x: pos, y: 5, width: size.width, height: size.height)
            button.addTarget(self, action: "handleCandidate:", forControlEvents: UIControlEvents.TouchUpInside)
            
            candidateScrollView.addSubview(button)
            
            pos += size.width + 2
        }
        candidateScrollView.contentSize = CGSize(width: pos, height: 40)
        return;
    }
    
    func handleCandidate(sender : UIButton) {
        session.handle(Int32(sender.tag), keycode: 0, mods: 9)
        candidateScrollView.removeFromSuperview()
        view.addSubview(compose)
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
            icon = "AA"
        case .NullMode:
            icon = "-"
        }
        modeButton.setTitle(icon, forState: .Normal)        
    }
}
