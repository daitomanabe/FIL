import Foundation
import CoreGraphics

// MARK: - Data Structures



struct FilSegment: Identifiable {
    let id: Int
    let sid: String
    let rect: CGRect
    var activeLevel: Double // 0.0 - 1.0
    var visible: Bool
    
    // Parsed from "c" logic from original
    // But we are doing B&W override generally, preventing color parsing complexity for now unless needed.
    // We will stick to white as per refinement.
}

// MARK: - Model

class FilModel: ObservableObject {
    @Published var segments: [FilSegment] = []
    
    // Animation State
    private var lastTime: TimeInterval = 0
    private var isSequenceActive: Bool = false
    private var isHolding: Bool = false
    private var holdStartTime: TimeInterval = 0
    private var lastStepTime: TimeInterval = 0
    private var currentPreset: String = "satellite"
    
    // Params
    private let paramSpeed: Double = 33.33 // ms
    private let paramFade: Double = 120.0  // ms
    private let paramProb: Double = 0.5
    
    // Sequencer
    private var animOrder: [Int] = []
    private var animIndex: Int = 0
    
    // Active Animations: [index: (startTime, duration)]
    private var activeAnims: [Int: (Double, Double)] = [:]
    
    init() {
        loadData()
        // Initial start
        startAnimationSequence()
    }
    
    private func loadData() {
        guard let url = Bundle(for: type(of: self)).url(forResource: "segments", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        self.segments = []
        var idx = 0

        // JSONは { "ok": true, "frame": {...}, "segments": [...] } の構造
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let segmentsArray = json["segments"] as? [[String: Any]] {
            for item in segmentsArray {
                if let id = item["id"] as? String,
                   let x = (item["x"] as? Double) ?? (item["x"] as? Int).map(Double.init),
                   let y = (item["y"] as? Double) ?? (item["y"] as? Int).map(Double.init),
                   let w = (item["w"] as? Double) ?? (item["w"] as? Int).map(Double.init),
                   let h = (item["h"] as? Double) ?? (item["h"] as? Int).map(Double.init) {

                    let rect = CGRect(x: x, y: y, width: w, height: h)
                    let s = FilSegment(id: idx, sid: id, rect: rect, activeLevel: 0.0, visible: true)
                    self.segments.append(s)
                    idx += 1
                }
            }
        }

        applyPreset("satellite")
    }
    
    func tick(timestamp: TimeInterval) {
        let nowMs = timestamp * 1000.0
        
        // 1. Check Hold
        // Detect falling edge of sequence
        // Actually simpler: if not active and not holding, start hold
        if !isSequenceActive && !isHolding {
            isHolding = true
            holdStartTime = nowMs
        }
        
        if isHolding {
            // Logic sync with ofApp:
            // if satellite -> wait 15000 (15s) then switch to Logo
            // if logo -> wait 3000 (3s) then switch to Satellite
            let holdDur = (currentPreset == "satellite") ? 7000.0 : 3000.0
            
            if nowMs - holdStartTime > holdDur {
                isHolding = false
                // Switch
                if currentPreset == "satellite" {
                    currentPreset = "wordmark"
                } else if currentPreset == "wordmark" {
                    currentPreset = "infrapositive"
                } else {
                    currentPreset = "satellite"
                }
                applyPreset(currentPreset)
                startAnimationSequence()
            }
        }
        
        // 2. SequencerStep
        if isSequenceActive {
            // logic ms check
            // For smoother loop, we might just step every N frames or check delta
            // Using loose timer
            if nowMs - lastStepTime > paramSpeed {
                stepAnimation(nowMs: nowMs)
                lastStepTime = nowMs
            }
        }
        
        // 3. Update Active Levels
        // Fade rate logic: 1.0 / (fadeMs / 1000.0) -> 1.0 per fadeSec
        let dt = 1.0 / 60.0
        let fadeRate = (paramFade > 0) ? (1000.0 / paramFade) : 8.33
        
        // Mutate segments
        // We need efficient updates. Doing this for 2000 items in Swift is fine.
        
        // First cleanup expired anims
        var nextAnims: [Int: (Double, Double)] = [:]
        for (idx, (start, dur)) in activeAnims {
            if nowMs - start <= dur {
                nextAnims[idx] = (start, dur)
            }
            // If expired, it just drops from activeAnims, so target becomes 0 (or 1 if visible static)
            // But wait, the logic is: if sequence active, target is strictly defined by activeAnims?
            // "if isSequenceActive: target = active ? 1 : 0"
        }
        self.activeAnims = nextAnims
        
        for i in 0..<segments.count {
            var target: Double = 0.0
            
            if !isSequenceActive {
                target = segments[i].visible ? 1.0 : 0.0
            } else {
                let isActive = activeAnims[i] != nil
                target = isActive ? 1.0 : 0.0
            }
            
            var level = segments[i].activeLevel
            if level < target {
                level = min(target, level + fadeRate * dt)
            } else if level > target {
                level = max(target, level - fadeRate * dt)
            }
            segments[i].activeLevel = level
        }
    }
    
    private func startAnimationSequence() {
        // Filter visible indices
        animOrder = segments.indices.filter { segments[$0].visible }
        animOrder.shuffle()
        
        animIndex = 0
        isSequenceActive = true
        lastStepTime = 0
        activeAnims.removeAll()
    }
    
    private func stepAnimation(nowMs: Double) {
        if animIndex >= animOrder.count {
            isSequenceActive = false
            return
        }
        
        // Batch size logic from original? Original was 1 per step (shuffled).
        // Let's do 1 per step.
        let idx = animOrder[animIndex]
        activeAnims[idx] = (nowMs, 500.0) // 500ms duration for "flash" or overlap
        
        animIndex += 1
    }
    
    private func applyPreset(_ name: String) {
        for i in 0..<segments.count {
            segments[i].visible = checkVisibility(segments[i], preset: name)
        }
    }
    
    private func checkVisibility(_ s: FilSegment, preset: String) -> Bool {
        if preset == "satellite" { return true }
        if preset == "wordmark" {
            // Logic from PHP/C++: "w_" prefix or similar. 
            // Original: "w_f", "w_i", "w_l"
            return s.sid.contains("w_f") || s.sid.contains("w_i") || s.sid.contains("w_l")
        }
        if preset == "infrapositive" {
             // Logic: "t_f", "t_i", "t_l"
             return s.sid.contains("t_f") || s.sid.contains("t_i") || s.sid.contains("t_l")
        }
        return false
    }
}
