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
    private var wasSequenceActive: Bool = true  // For detecting falling edge
    private var isHolding: Bool = false
    private var holdStartTime: TimeInterval = 0
    private var lastStepTime: TimeInterval = 0
    private var currentPreset: String = "satellite"
    
    // Params
    private let paramSpeed: Double = 235.3 // ms (4000ms / 17 steps)
    private let paramFade: Double = 0.0    // ms
    private let paramOverlap: Double = 50.0 // ms

    
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

        // 1. Check Hold - detect falling edge (wasAnimating && !isAnimating)
        if wasSequenceActive && !isSequenceActive {
            isHolding = true
            holdStartTime = nowMs
        }
        wasSequenceActive = isSequenceActive

        if isHolding {
            // Logic sync with ofApp:
            // Fixed 1.0s hold for all states
            let holdDur = 1000.0
            
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
        // Force immediate start by setting lastStepTime to allow first step
        lastStepTime = -paramSpeed
        activeAnims.removeAll()
    }
    
    private func stepAnimation(nowMs: Double) {
        if animIndex >= animOrder.count {
            isSequenceActive = false
            return
        }

        // Clear previous anims if no overlap (matching ofApp behavior)
        if paramOverlap <= 0 {
            activeAnims.removeAll()
        }

        let idx = animOrder[animIndex]
        let dur = (paramOverlap <= 0) ? paramSpeed : (paramSpeed + paramOverlap)
        activeAnims[idx] = (nowMs, dur)

        animIndex += 1
    }
    
    private func applyPreset(_ name: String) {
        // Segment IDs matching ofApp.cpp
        let wordmarkIds = ["V_TL_01", "V_TM_01", "V_TR_01",
                           "V_BL_01", "V_BM_01", "V_BR_01",
                           "H_TL_01", "H_ML_01", "H_BR_01"]

        let infraposIds = ["V_TM_01", "V_BM_01", "H_TL_01", "H_ML_01",
                           "H_MR_01", "H_BR_01", "H_MM_01"]

        for i in 0..<segments.count {
            switch name {
            case "satellite":
                segments[i].visible = true
            case "wordmark":
                segments[i].visible = wordmarkIds.contains(segments[i].sid)
            case "infrapositive":
                segments[i].visible = infraposIds.contains(segments[i].sid)
            default:
                segments[i].visible = false
            }
        }
    }
}
