//
//  AppDelegate.swift
//  Dimmer Bar
//
//  Created by phucld on 12/17/19.
//  Copyright © 2019 Dwarves Foundation. All rights reserved.
//

import Cocoa
import HotKey
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusBarController = StatusBarController()

  var hotKey: HotKey? {
    didSet {
      guard let hotKey = hotKey else { return }

      hotKey.keyDownHandler = {
        DimManager.sharedInstance.setting.isEnabled.toggle()
      }
    }
  }

  let eventMonitor = EventMonitor(mask: .leftMouseUp) { _ in
    // Hanlde this without delay
    DimManager.sharedInstance.dim(runningApplication: NSWorkspace.shared.frontmostApplication, withDelay: false)
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    hideDockIcon()
    setupAutoStartAtLogin()
    openPrefWindowIfNeeded()
    setupHotKey()
    eventMonitor.start()
  }

  func applicationDidChangeScreenParameters(_ notification: Notification) {
    DimManager.sharedInstance.dim(runningApplication: NSWorkspace.shared.frontmostApplication)
  }

  func setupHotKey() {
    guard let globalKey = UserDefaults.globalKey else { return }
    hotKey = HotKey(keyCombo: KeyCombo(carbonKeyCode: globalKey.keyCode, carbonModifiers: globalKey.carbonFlags))
  }

  func openPrefWindowIfNeeded() {
    if UserDefaults.isOpenPrefWhenOpenApp {
      PreferencesWindowController.shared.window?.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
  }

  func setupAutoStartAtLogin() {
    let isAutoStart = UserDefaults.isStartWhenLogin
    Util.setUpAutoStart(isAutoStart: isAutoStart)
  }

  func hideDockIcon() {
    NSApp.setActivationPolicy(.accessory)
  }
}
