import UIKit
import Foundation

class EmotionColors {
    static let shared = EmotionColors()
    
    private var colorMapping: [String: UIColor] = [:]
    
    private init() {
        setupDefaultColors()
        loadColorMappingFromJSON()
    }
    
    private func setupDefaultColors() {
        // Default emotion-to-color mapping
        colorMapping = [
            // Positive emotions
            "joy": UIColor.systemYellow,
            "excitement": UIColor.systemOrange,
            "love": UIColor.systemPink,
            "optimism": UIColor.systemBlue,
            "amusement": UIColor.systemYellow,
            "approval": UIColor.systemGreen,
            "caring": UIColor.systemPink,
            "desire": UIColor.systemRed,
            "gratitude": UIColor.systemGreen,
            "pride": UIColor.systemPurple,
            "relief": UIColor.systemTeal,
            "admiration": UIColor.systemBlue,
            
            // Negative emotions
            "anger": UIColor.systemRed,
            "sadness": UIColor.systemBlue,
            "fear": UIColor.systemGray,
            "disgust": UIColor.systemBrown,
            "disappointment": UIColor.systemGray2,
            "disapproval": UIColor.systemRed,
            "embarrassment": UIColor.systemPink,
            "grief": UIColor.systemGray,
            "nervousness": UIColor.systemOrange,
            "remorse": UIColor.systemGray,
            "annoyance": UIColor.systemOrange,
            
            // "Neutral" emotions
            "neutral": UIColor.systemGray3,
            "curiosity": UIColor.systemCyan,
            "confusion": UIColor.systemYellow,
            "realization": UIColor.systemTeal,
            "surprise": UIColor.systemYellow,
            "others": UIColor.systemGray4
        ]
    }
    
    private func loadColorMappingFromJSON() {
        guard let url = Bundle.main.url(forResource: "emotion_color_mapping", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("⚠️ Could not load emotion_color_mapping.json, using defaults")
            return
        }
        
        for (emotion, colorData) in json {
            if let colorDict = colorData as? [String: Any],
               let red = colorDict["red"] as? Double,
               let green = colorDict["green"] as? Double,
               let blue = colorDict["blue"] as? Double {
                
                let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
                colorMapping[emotion.lowercased()] = color
            }
        }
        
        print("✅ Loaded color mappings for \(colorMapping.count) emotions")
    }
    
    func color(for emotion: String) -> UIColor {
        let normalizedEmotion = emotion.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return colorMapping[normalizedEmotion] ?? colorMapping["neutral"] ?? UIColor.systemGray3
    }
    
    func bubbleGradient(for emotion: String) -> [UIColor] {
        let baseColor = color(for: emotion)
        let lighterColor = baseColor.withBrightness(1.2) // Brighter version
        let darkerColor = baseColor.withBrightness(0.8)  // Darker version
        
        return [lighterColor, baseColor, darkerColor]
    }
    
    func availableEmotions() -> [String] {
        return Array(colorMapping.keys).sorted()
    }
}

// UIColor extension for brightness adjustment
extension UIColor {
    func withBrightness(_ brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        return self
    }
} 
