import Cocoa

class WindowManager: NSObject, NSWindowDelegate {
    var window: CustomWindow!
    var closeButton: NSButton!
    var titleBarView: DraggableTitleBar!
    var textView: CustomTextView!
    var backgroundView: NSView!
    var isHalfTransparent: Bool = false

    func setupMainWindow() {
        setupWindow()
        setupBackgroundView()
        setupTitleBar()
        setupCloseButton()
        setupTextView()
        ColorMenuManager.shared.addColorMenuItems(target: self)
        updateCloseButtonColor()

        // Explicitly show the close button after setting up the window
        showCloseButtonIfNeeded()
    }

    private func setupWindow() {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
        let windowSize = CGSize(width: 300, height: 300)
        let windowFrame = NSRect(x: (screenSize.width - windowSize.width) / 2, y: (screenSize.height - windowSize.height) / 2, width: windowSize.width, height: windowSize.height)

        window = CustomWindow(contentRect: windowFrame, styleMask: [.borderless, .resizable], backing: .buffered, defer: false)
        window.delegate = self // Set the delegate here
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
    }

    private func setupBackgroundView() {
        backgroundView = NSView(frame: window.frame)
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 10
        backgroundView.layer?.masksToBounds = true
        backgroundView.layer?.backgroundColor = NSColor.yellow.cgColor
        window.contentView = backgroundView
    }

    private func setupTitleBar() {
        titleBarView = DraggableTitleBar(frame: NSRect(x: 0, y: backgroundView.frame.height - 20, width: backgroundView.frame.width, height: 20))
        titleBarView.wantsLayer = true
        titleBarView.layer?.backgroundColor = NSColor.clear.cgColor
        titleBarView.layer?.cornerRadius = 10
        titleBarView.autoresizingMask = [.width, .minYMargin]
        backgroundView.addSubview(titleBarView)
    }

    private func setupCloseButton() {
        closeButton = NSButton(frame: NSRect(x: 5, y: 2, width: 16, height: 16))
        closeButton.bezelStyle = .regularSquare
        closeButton.isBordered = false
        closeButton.isHidden = true // Initially hidden
        closeButton.target = self
        closeButton.action = #selector(closeWindow)
        closeButton.autoresizingMask = [.maxXMargin, .minYMargin]
        titleBarView.addSubview(closeButton)
    }

    private func setupTextView() {
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: backgroundView.frame.width, height: backgroundView.frame.height - 20))
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.autoresizingMask = [.width, .height]

        textView = CustomTextView(frame: scrollView.bounds)
        textView.autoresizingMask = [.width, .height]
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.isEditable = true
        textView.isRichText = false
        textView.allowsUndo = true
        scrollView.documentView = textView
        backgroundView.addSubview(scrollView)
    }

    @objc func closeWindow() {
        window.close()
    }

    func windowDidBecomeKey(_ notification: Notification) {
        showCloseButtonIfNeeded()
    }

    func windowDidResignKey(_ notification: Notification) {
        hideCloseButtonIfNeeded()
    }

    private func showCloseButtonIfNeeded() {
        if closeButton != nil {
            closeButton.isHidden = false
        }
    }

    private func hideCloseButtonIfNeeded() {
        if closeButton != nil {
            closeButton.isHidden = true
        }
    }

    @objc func changeBackgroundColor(_ sender: NSMenuItem) {
        if let hex = sender.representedObject as? String, let color = NSColor(hex: hex) {
            backgroundView.layer?.backgroundColor = color.cgColor
            updateCloseButtonColor()
        }
    }

    @objc func toggleTransparency() {
        isHalfTransparent.toggle()
        ColorMenuManager.shared.addColorMenuItems(target: self)
    }

    private func updateCloseButtonColor() {
        if let bgColor = backgroundView.layer?.backgroundColor, let bgNSColor = NSColor(cgColor: bgColor) {
            closeButton.attributedTitle = NSAttributedString(string: "✕", attributes: [.foregroundColor: contrastColor(for: bgNSColor)])
        }
    }

    private func contrastColor(for color: NSColor) -> NSColor {
        let lum = 0.299 * color.redComponent + 0.587 * color.greenComponent + 0.114 * color.blueComponent
        return lum > 0.5 ? .black : .white
    }
}
