//
//  KeyboardViewController.swift
//  SKK for iOS
//
//  Created by mzp on 2014/09/18.
//  Copyright (c) 2014年 codefirst. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, WrapperParameter {
    enum Keycode : Int {
        case Switch = 1,
        Alphabet,
        Space,
        Shift,
        BackSpace,
        Enter
    }
    
    var session : SKKWrapper = SKKWrapper()
    
    let compose : UILabel = UILabel()
    
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
            (" ", .Alphabet),
            (" ", .Space)
        ]
    ]
    
    enum Modifier : Int {
        case Shift = 1, Ctrl = 2, Alt = 4, Meta = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // compose
        compose.text = "welcome to SKK for iOS"
        compose.frame = CGRect(x: 10, y:0 , width: 300, height: 35)
        view.addSubview(compose)
        
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
                session.handle(Int32(n), keycode: 0, mods: Int32(mods))
                mods = 0
            case .Shift:
                mods = Modifier.Shift.toRaw()
            case .Enter:
                session.handle(0x0a, keycode: 0, mods: Int32(mods))
                mods = 0
            default:
                ()
            }
        }
    }
    
    func insertText(text: String!) {
        (self.textDocumentProxy as UITextDocumentProxy).insertText(text)
    }
    
    func composeText(text: String!) {
        compose.text = text
    }

}
