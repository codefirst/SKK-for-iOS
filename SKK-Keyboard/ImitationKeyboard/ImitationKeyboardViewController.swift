//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

class ImitationKeyboardViewController: UIInputViewController {
    
    let backspaceDelay: NSTimeInterval = 0.5
    let backspaceRepeat: NSTimeInterval = 0.05
    let infoViewHeight : CGFloat = 30
    
    var infoView : UIView
    var keyboard: Keyboard
    var forwardingView: ForwardingView
    var layout: KeyboardLayout
    var heightConstraint: NSLayoutConstraint?
    
    var currentMode: Int {
        didSet {
            setMode(currentMode)
        }
    }
    
    var backspaceActive: Bool {
        get {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    var backspaceDelayTimer: NSTimer?
    var backspaceRepeatTimer: NSTimer?
    
    enum ShiftState {
        case Disabled
        case Enabled
        case Locked
    }
    var shiftState: ShiftState {
        didSet {
            switch shiftState {
            case .Disabled:
                self.updateKeyCaps(true)
            case .Enabled:
                self.updateKeyCaps(false)
            case .Locked:
                self.updateKeyCaps(false)
            }
        }
    }

    // TODO: why does the app crash if this isn't here?
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.keyboard = defaultKeyboard()
        self.forwardingView = ForwardingView(frame: CGRectZero)
        self.forwardingView.translatesAutoresizingMaskIntoConstraints = false
        self.layout = KeyboardLayout(model: self.keyboard, superview: self.forwardingView)
        self.shiftState = .Disabled
        self.currentMode = 0
        self.infoView = UIView(frame: CGRectZero)
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.addSubview(self.forwardingView)
        self.view.addSubview(self.infoView)
        
        // infoView
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.infoView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1,
                constant: 0))
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.infoView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1,
                constant: 0))
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.infoView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: 0))
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.infoView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: infoViewHeight))
        
        // keyboard
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.forwardingView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1,
                constant: 0))
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.forwardingView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1,
                constant: 0))
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.forwardingView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: infoViewHeight))
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.forwardingView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: 0))
        
        // TODO: figure out where to move this
        self.layout.initialize()
        self.setupKeys()
        
        // TODO: read up on swift setter behavior on init
        self.setMode(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func updateViewConstraints() {
        // suppresses constraint unsatisfiability on initial zero rect; mostly an issue of log spam
        // TODO: there's probably a more sensible/correct way to do this
        if CGRectIsEmpty(self.view.bounds) {
            NSLayoutConstraint.deactivateConstraints(self.layout.allConstraintObjects)
        }
        else {
            NSLayoutConstraint.activateConstraints(self.layout.allConstraintObjects)
        }
        
        super.updateViewConstraints()
    }
    
    func setupKeys() {
        for page in keyboard.pages {
            for rowKeys in page.rows { // TODO: quick hack
                for key in rowKeys {
                    let keyView = self.layout.viewForKey(key)! // TODO: check
                    
                    let showOptions: UIControlEvents = [.TouchDown, .TouchDragInside, .TouchDragEnter]
                    let hideOptions: UIControlEvents = [.TouchUpInside, .TouchUpOutside, .TouchDragOutside]
                    
                    switch key.type {
                    case Key.KeyType.KeyboardChange:
                        keyView.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
                    case Key.KeyType.Backspace:
                        let cancelEvents: UIControlEvents = [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpInside, UIControlEvents.TouchDragExit, UIControlEvents.TouchUpOutside, UIControlEvents.TouchCancel, UIControlEvents.TouchDragOutside]
                        
                        keyView.addTarget(self, action: "backspaceDown:", forControlEvents: .TouchDown)
                        keyView.addTarget(self, action: "backspaceUp:", forControlEvents: cancelEvents)
                    case Key.KeyType.Shift:
                        keyView.addTarget(self, action: Selector("shiftDown:"), forControlEvents: .TouchUpInside)
                        keyView.addTarget(self, action: Selector("shiftDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                    case Key.KeyType.ModeChange:
                        keyView.addTarget(self, action: Selector("modeChangeTapped"), forControlEvents: .TouchUpInside)
                    case Key.KeyType.InputModeChange:
                        keyView.addTarget(self, action: Selector("inputModeChangeTapped"), forControlEvents: .TouchUpInside)
                    default:
                        break
                    }
                    
                    if key.outputText != nil {
                        keyView.addTarget(self, action: "keyPressed:", forControlEvents: .TouchUpInside)
    //                    keyView.addTarget(self, action: "takeScreenshotDelay", forControlEvents: .TouchDown)
                    }
                    
                    if key.type == Key.KeyType.Character || key.type == Key.KeyType.Period {
                        keyView.addTarget(keyView, action: Selector("showPopup"), forControlEvents: showOptions)
                        keyView.addTarget(keyView, action: Selector("hidePopup"), forControlEvents: hideOptions)
                    }
                    
                    //        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
                    //        self.nextKeyboardButton.sizeToFit()
                }
            }
        }
    }
    
    func takeScreenshotDelay() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("takeScreenshot"), userInfo: nil, repeats: false)
    }
    
    func takeScreenshot() {
        if !CGRectIsEmpty(self.view.bounds) {
            UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
            
            let oldViewColor = self.view.backgroundColor
            self.view.backgroundColor = UIColor(hue: (216/360.0), saturation: 0.05, brightness: 0.86, alpha: 1)
            
            var rect = self.view.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
            var context = UIGraphicsGetCurrentContext()
            self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
            var capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let name = (self.interfaceOrientation.isPortrait ? "Screenshot-Portrait" : "Screenshot-Landscape")
            var imagePath = "/Users/archagon/Documents/Programming/OSX/TransliteratingKeyboard/\(name).png"
            UIImagePNGRepresentation(capturedImage)?.writeToFile(imagePath, atomically: true)
            
            self.view.backgroundColor = oldViewColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    var blah = 0
    func keyPressed(sender: KeyboardKey) {
        UIDevice.currentDevice().playInputClick()
        if self.shiftState == .Enabled {
            self.shiftState = .Disabled
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    func backspacePressed() {}
    
    func backspaceDown(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        
        // first delete
        UIDevice.currentDevice().playInputClick()
        backspacePressed()
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceDelay - backspaceRepeat, target: self, selector: Selector("backspaceDelayCallback"), userInfo: nil, repeats: false)
    }
    
    func backspaceUp(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
    }
    
    func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceRepeat, target: self, selector: Selector("backspaceRepeatCallback"), userInfo: nil, repeats: true)
    }
    
    func backspaceRepeatCallback() {
        backspacePressed()
    }
    
    func shiftDown(sender: KeyboardKey) {
        switch self.shiftState {
        case .Disabled:
            self.shiftState = .Enabled
            sender.highlighted = true
        case .Enabled:
            self.shiftState = .Disabled
            sender.highlighted = false
        case .Locked:
            self.shiftState = .Disabled
            sender.highlighted = false
        }
        
        sender.text = "⇪"
    }
    
    func shiftDoubleTapped(sender: KeyboardKey) {
        switch self.shiftState {
        case .Disabled:
            self.shiftState = .Locked
            sender.highlighted = true
        case .Enabled:
            self.shiftState = .Locked
            sender.highlighted = true
        case .Locked:
            self.shiftState = .Locked
            sender.highlighted = true
        }
        
        sender.text = "L"
    }
    
    func updateKeyCaps(lowercase: Bool) {
        for (model, key) in self.layout.modelToView {
            key.text = (lowercase ? model.lowercaseKeyCap : model.keyCap)
        }
    }
    
    func modeChangeTapped() {
        self.currentMode = ((self.currentMode + 1) % 3)
    }
    
    func setMode(mode: Int) {
        for (pageIndex, page) in self.keyboard.pages.enumerate() {
            for (rowIndex, row) in page.rows.enumerate() {
                for (keyIndex, key) in row.enumerate() {
                    if self.layout.modelToView[key] != nil {
                        let keyView = self.layout.modelToView[key]
                        keyView?.hidden = (pageIndex != mode)
                    }
                }
            }
        }
    }
}
