import SwiftUI

struct FilView: View {
    @ObservedObject var model: FilModel
    
    // Grid dims
    let gw: Double = 1450.0
    let gh: Double = 860.0
    
    var body: some View {
        Canvas { context, size in
            // 1. Fill Background
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
            
            // 2. Calc Scale & Center
            let padding: Double = 50.0
            let availW = size.width - padding * 2
            let availH = size.height - padding * 2
            let s = min(availW / gw, availH / gh)
            
            let dx = (size.width - gw * s) / 2.0
            let dy = (size.height - gh * s) / 2.0
            
            // 3. Transform
            context.translateBy(x: dx, y: dy)
            context.scaleBy(x: s, y: s)
            
            // 4. Draw Segments
            for segment in model.segments {
                if segment.activeLevel > 0.01 {
                    let alpha = segment.activeLevel
                    // Rect Flip: Original JSON y=0 is Top. Canvas y=0 is Top.
                    // Wait, in the ObjC version we flipped because we thought it was needed.
                    // If JSON is Top-Left (HTML style), and Canvas is Top-Left, NO FLIP needed.
                    // ObjC Cocoa is Bottom-Left, so we flipped.
                    // So simply specificy rect.
                    
                    let r = segment.rect
                    let path = Path(r)
                    
                    context.opacity = alpha
                    context.fill(path, with: .color(.white))
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
