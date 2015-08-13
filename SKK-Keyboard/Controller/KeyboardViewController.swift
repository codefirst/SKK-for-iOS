//
//  KeyboardViewController.swift
//  SKK for iOS
//
//  Created by mzp on 2014/09/18.
//  Copyright (c) 2014年 codefirst. All rights reserved.
//

import UIKit

class KeyboardViewController: ImitationKeyboardViewController, AquaSKKSessionDelegate, UITableViewDelegate {
    var session : AquaSKKSession
    
    var compose : UILabel = UILabel()
    
    var candidateView : UITableView
    var dataSource : CandidateDataSource = CandidateDataSource()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        // AquaSKK session
        // TODO: need async load?
        self.session = AquaSKKSession()
        let width = UIScreen.mainScreen().bounds.width

        // candidate
        // TODO: Use auto layout
        candidateView = UITableView(frame: CGRect(x: 0, y:40, width:width, height:UIScreen.mainScreen().bounds.width - 40), style: .Plain)
        candidateView.dataSource = dataSource
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        candidateView.delegate = self

        // compose
        compose.text = "welcome to SKK for iOS"
        compose.font = UIFont.systemFontOfSize(18)
        compose.frame = CGRect(x: 10, y:0 , width: width, height: 40)
        infoView.addSubview(compose)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.setDelegate(self)
    }
    
    // callback from AquaSKK session
    func insertText(text: String!) {
        (self.textDocumentProxy as UIKeyInput).insertText(text)
    }
    
    func composeText(text: String!) {
        compose.text = text
    }
    
    func updateCandidate(xs: NSMutableArray) {
        if(xs.count <= 1 ) { return }
        
        var ys : [String] = [String]()
        for x in xs {
            ys.append((x as! NSString) as String)
        }
        
        self.view.addSubview(candidateView)
        self.forwardingView.hidden = true
        dataSource.update(ys)
        candidateView.reloadData()
    }

    func selectInputMode(mode : InputMode) {
        var icon = ""
        switch mode {
        case .HirakanaMode:
            icon = "あ"
        case .KatakanaMode:
            icon = "ア"
        case .AsciiMode:
            icon = "@"
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

    // TableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.session.handle(Int32(indexPath.row + 0x21), keycode: 0, mods: 0)
        self.candidateView.removeFromSuperview()
        self.forwardingView.hidden = false
    }
    
    // callback from keyboard
    private func handle(charcode: CChar){
        let b = session.handle(Int32(charcode), keycode: 0, mods: 0)
        if(!b) {
            if(charcode != 0x08){
                let input : UIKeyInput? = (self.textDocumentProxy as UIKeyInput)
                let str = String(UnicodeScalar(Int(charcode)))
                input?.insertText(str)
            }else{
                (self.textDocumentProxy as UIKeyInput).deleteBackward()
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
