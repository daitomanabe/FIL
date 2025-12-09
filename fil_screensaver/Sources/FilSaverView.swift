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
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.autoresizingMask = [.width, .height]
        self.animationTimeInterval = 1.0/60.0
        self.wantsLayer = true
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
        // No setNeedsDisplay needed? SwiftUI @Published should trigger invalidation.
        // However, NSHostingView might need explicit trigger if external loop drives it?
        // Actually, ObservableObject update triggers View body re-eval.
        // But since we are in a RunLoop provided by ScreenSaverEngine, we rely on SwiftUI's sync.
        // It might be safer to let SwiftUI drive itself? No, standard is animateOneFrame.
        // Let's rely on model update -> objectWillChange -> View update.
        // If not, we might need to verify.
    }
}
