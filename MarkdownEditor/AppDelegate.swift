//
//  AppDelegate.swift
//  MarkdownEditor
//
//  Created by Mac Mini on 3/9/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var firstWindow = true
    var lastDocument: URL?  // Save for reopening next time

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Three possible states: last file, no file, open file
        // print("App did finish loading")
        lastDocument = UserDefaults.standard.url(forKey: "lastDocument")
        let app = aNotification.object as! NSApplication
        
        if let vc = app.mainWindow?.contentViewController as? ViewController {
            if lastDocument == nil {
                vc.loadSampleDocument()
            } else {
                // Already loaded as first Document
            }
        } else {
            print("VC not loaded yet")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

