//
//  PixelPerfectApp.swift
//  PixelPerfect
//
//  Created by wader zhang on 2025/7/11.
//

import SwiftUI

class ComparisonWindowController: NSWindowController {
    private let windowManager: WindowManager
    
    init(imageModel: ImageModel, themeManager: ThemeManager, windowManager: WindowManager) {
        self.windowManager = windowManager
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.center()
        window.title = "Image Comparison"
        window.contentView = NSHostingView(rootView: ComparisonView(imageModel: imageModel, themeManager: themeManager))
        window.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ComparisonWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        windowManager.removeWindow(self)
    }
}

// Generic window controller for info pages
class InfoWindowController: NSWindowController {
    private let windowManager: WindowManager
    
    init<Content: View>(title: String, content: Content, windowManager: WindowManager) {
        self.windowManager = windowManager
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.center()
        window.title = title
        window.contentView = NSHostingView(rootView: content)
        window.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InfoWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        windowManager.removeInfoWindow(self)
    }
}

class WindowManager: ObservableObject {
    private var comparisonWindows: Set<ComparisonWindowController> = []
    private var infoWindows: Set<InfoWindowController> = []
    private let themeManager = ThemeManager()
    
    func showComparisonWindow(with imageModel: ImageModel, themeManager: ThemeManager) {
        let windowController = ComparisonWindowController(imageModel: imageModel, themeManager: themeManager, windowManager: self)
        comparisonWindows.insert(windowController)
        windowController.showWindow(nil)
    }
    
    func removeWindow(_ windowController: ComparisonWindowController) {
        comparisonWindows.remove(windowController)
    }
    
    func showPrivacyWindow() {
        let windowController = InfoWindowController(
            title: "Privacy Policy",
            content: PrivacyView(themeManager: themeManager),
            windowManager: self
        )
        infoWindows.insert(windowController)
        windowController.showWindow(nil)
    }
    
    func showTermsWindow() {
        let windowController = InfoWindowController(
            title: "Terms of Service",
            content: TermsView(themeManager: themeManager),
            windowManager: self
        )
        infoWindows.insert(windowController)
        windowController.showWindow(nil)
    }
    
    func showSupportWindow() {
        let windowController = InfoWindowController(
            title: "Support",
            content: SupportView(themeManager: themeManager),
            windowManager: self
        )
        infoWindows.insert(windowController)
        windowController.showWindow(nil)
    }
    
    func removeInfoWindow(_ windowController: InfoWindowController) {
        infoWindows.remove(windowController)
    }
}

@main
struct PixelPerfectApp: App {
    @StateObject private var windowManager = WindowManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(windowManager)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                // Remove default "New" menu item to prevent confusion
            }
            
            CommandGroup(after: .help) {
                Button("Privacy Policy") {
                    windowManager.showPrivacyWindow()
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])
                
                Button("Terms of Service") {
                    windowManager.showTermsWindow()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
                
                Button("Support") {
                    windowManager.showSupportWindow()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }
    }
}
