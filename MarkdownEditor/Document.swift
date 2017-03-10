//
//  Document.swift
//  MarkdownEditor
//
//  Created by Mac Mini on 3/9/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    var windowController: NSWindowController?
    var content: String = ""

    override init() {
        super.init()
        
        let app = NSApp.delegate as! AppDelegate
        
        if app.firstWindow {
            app.firstWindow = false
            openLastDocument()
        }

    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    
    // Open last document
    func openLastDocument() {
        Swift.print("Open last document")
        if let url = UserDefaults.standard.url(forKey: "lastDocument") {
            let app = NSApp.delegate as! AppDelegate
            app.lastDocument = url
            Swift.print("Opening file: ", url)
            try? self.read(from: url, ofType: "md")
            self.fileURL = url
        }
    }
    
    override func close() {
        Swift.print("Close: ", self.fileURL)
        saveLastDocumentUrl()
        super.close()
    }

    // Save last table url in UserDefaults
    func saveLastDocumentUrl() {
        Swift.print("Save last doc url")
        if let url = self.fileURL {
            UserDefaults.standard.set(url, forKey: "lastDocument")
            Swift.print("Saving url: ", url)
        }
    }
    
    // Open
    override func read(from data: Data, ofType typeName: String) throws {
        //Swift.print("Open: ", typeName)
        //Swift.print("File: ", self.fileURL)
        
        if let text = String(data: data, encoding: .utf8) {
            content = text
            //Swift.print("Text: \n", text)
        } else {
            Swift.print("Error reading file")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }

    // Save
    override func data(ofType typeName: String) throws -> Data {
        Swift.print("Save: ", typeName)
        
        /*
         guard let text = textView?.string else {
         debugPrint("No text for saving?")
         throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
         }
         */
        
        guard let viewController = windowController?.contentViewController as? ViewController else {
            Swift.print("No text for saving?")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        viewController.notifySave()
        let text = viewController.textEditor.string ?? ""
        Swift.print("Saving text to ", self.fileURL)
        
        if let data = text.data(using: .utf8) {
            return data
        } else {
            Swift.print("No data for saving?")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        
    }

    // Assign content to view
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        
        // Custom code
        self.windowController = windowController
        //Swift.print("WC added")
        
        if let viewController = windowController.contentViewController as? ViewController {
            viewController.textEditor.string = content
            viewController.updateViewers()
            //Swift.print("TextView added")
        }
    }


}

