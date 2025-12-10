import ScreenSaver
import SwiftUI

@objc class FilSaverView: ScreenSaverView {
    
    private var model: FilModel!
    private var hostingView: NSHostingView<FilView>?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.autoresizingMask = [.width, .height]
        self.animationTimeInterval = 1.0/60.0
        self.wantsLayer = true
        self.layer?.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.autoresizingMask = [.width, .height]
        self.animationTimeInterval = 1.0/60.0
        self.wantsLayer = true
        self.layer?.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
        setup()
    }
    
    private func setup() {
        model = FilModel()
        let view = FilView(model: model)
        hostingView = NSHostingView(rootView: view)
        
        if let hv = hostingView {
            hv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(hv)
            
            NSLayoutConstraint.activate([
                hv.leadingAnchor.constraint(equalTo: leadingAnchor),
                hv.trailingAnchor.constraint(equalTo: trailingAnchor),
                hv.topAnchor.constraint(equalTo: topAnchor),
                hv.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        // SwiftUI handles drawing
    }
    
    override func animateOneFrame() {
        // Drive the model's tick
        let now = Date().timeIntervalSinceReferenceDate
        model.tick(timestamp: now)
    }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window = window {
            self.layer?.contentsScale = window.backingScaleFactor
        }
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        // Ensure SwiftUI view invalidates if needed, though constraints usually handle it.
        // We force a layout pass just in case.
        hostingView?.needsLayout = true
        hostingView?.layoutSubtreeIfNeeded()
    }
}
