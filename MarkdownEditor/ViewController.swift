//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Mac Mini on 3/9/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, NSTextStorageDelegate {
    
    var template = ""

    @IBOutlet var textEditor: NSTextView!
    @IBOutlet var textViewer: NSTextView!
    @IBOutlet weak var htmlViewer: WebView!
    @IBOutlet weak var tabViewer: NSTabView!
    @IBOutlet weak var buttonSave: NSButton!
    
    @IBAction func buttonHtml(_ sender: AnyObject) {
        toggleHtmlView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }

    func start() {
        print("Hello!")
        
        textEditor.font = NSFont.init(name: "Helvetica Neue", size: 16.0)
        textViewer.font = NSFont.init(name: "Helvetica Neue", size: 16.0)
        
        textEditor.textStorage?.delegate = self

        let url = Bundle.main.url(forResource: "template", withExtension: "html")
        
        do {
            template = try String(contentsOf: url!)
        } catch {
            template = "<pre>* Error loading template *</pre><p>{{TEXT}}</p>"
        }
    }

    func loadSampleDocument() {
        let url = Bundle.main.url(forResource: "sample", withExtension: "html")
        //print("URL: ", url?.path)
        var sample = ""
        
        do {
            sample = try String(contentsOf: url!)
        } catch {
            sample = "** Error loading sample file **"
        }
        
        textEditor.string = sample
        updateViewers()
    }
    
    func toggleHtmlView() {
        if tabViewer.indexOfTabViewItem(tabViewer.selectedTabViewItem!) == 0 {
            tabViewer.selectTabViewItem(at: 1)
        } else {
            tabViewer.selectTabViewItem(at: 0)
        }
    }
    
    func updateViewers() {
        let mkdn = textEditor.string ?? ""
        let text = Markdown().parse(mkdn)
        let html = template.replacingOccurrences(of: "{{TEXT}}", with: text)
        textViewer.string = text
        htmlViewer.mainFrame.loadHTMLString(html, baseURL: nil)
    }

    func notifySave() {
        let timer1: DispatchTime = .now() + .milliseconds(0500)
        let timer2: DispatchTime = .now() + .milliseconds(3000)
        
        DispatchQueue.main.asyncAfter(deadline: timer1) {
            self.buttonSave.image = NSImage(named: "icon_saved")
        }
        
        DispatchQueue.main.asyncAfter(deadline: timer2) {
            self.buttonSave.image = NSImage(named: "icon_save")
        }
    }
    
    // TEXT EDITOR
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        //print("Delta \(delta) - Mask: \(editedMask.rawValue)")
        if delta != 0 && editedMask.rawValue > 1 {
            // TODO: Optimize to only update latest range
            updateViewers()
        }
    }

}

