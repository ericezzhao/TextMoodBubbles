import Foundation
import CoreML
import NaturalLanguage

class EmotionDetector {
    private var model: MLModel?
    private var isModelLoaded = false
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        // Try multiple bundle locations for Messages extensions
        var modelURL: URL?
        
        // Try current bundle first
        modelURL = Bundle.main.url(forResource: "EmotionClassifier", withExtension: "mlmodel")
        
        // Try without extension (for compiled model)
        if modelURL == nil {
            modelURL = Bundle.main.url(forResource: "EmotionClassifier", withExtension: "mlmodelc")
        }
        
        // Try finding compiled model (for compiled model)
        if modelURL == nil {
            modelURL = Bundle.main.url(forResource: "EmotionClassifier", withExtension: nil)
        }
        
        guard let finalModelURL = modelURL else {
            print("❌ Could not find EmotionClassifier model in bundle")
            print("Bundle path: \(Bundle.main.bundlePath)")
            print("Bundle resources: \(Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil))")
            return
        }
        
        do {
            model = try MLModel(contentsOf: finalModelURL)
            isModelLoaded = true
            print("✅ EmotionClassifier model loaded successfully from: \(finalModelURL.path)")
            
            // Debug: Check model structure (for CreateML)
            print("📊 Model input descriptions: \(model!.modelDescription.inputDescriptionsByName)")
            print("📊 Model output descriptions: \(model!.modelDescription.outputDescriptionsByName)")
            
            // Check if it's a classifier (for CreateML)
            if let classifierLabels = model!.modelDescription.classLabels {
                print("📊 Model has \(classifierLabels.count) class labels")
                print("📊 First 10 labels: \(Array(classifierLabels.prefix(10)))")
            }
        } catch {
            print("❌ Failed to load EmotionClassifier model: \(error)")
        }
    }
    
    func detectEmotion(from text: String) -> String {
        guard isModelLoaded, let model = model else {
            print("⚠️ Model not loaded, returning default emotion")
            return "neutral"
        }
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "neutral"
        }
        
        do {
            // Create feature provider for text input (for CreateML)
            let inputFeatures: [String: Any] = ["text": text]
            let provider = try MLDictionaryFeatureProvider(dictionary: inputFeatures)
            
            let prediction = try model.prediction(from: provider)
            
            // Extract the predicted emotion (for CreateML)
            if let output = prediction.featureValue(for: "label")?.stringValue {
                print("🎯 Raw model output: \(output) for text: '\(text)'")
                
                // Parse multi-label output (e.g., "joy,excitement,love" -> "joy") common issue
                let primaryEmotion = parseMultiLabelOutput(output)
                print("🎯 Primary emotion: \(primaryEmotion)")
                return primaryEmotion
            } else {
                print("⚠️ Could not extract emotion from prediction")
                return "neutral"
            }
        } catch {
            print("❌ Prediction error: \(error)")
            return "neutral"
        }
    }
    
    func detectEmotionWithConfidence(from text: String) -> (emotion: String, confidence: Double) {
        let emotion = detectEmotion(from: text)
        // For now, return a base confidence. In a real app, you'd extract this from the model
        let confidence = 0.75
        return (emotion, confidence)
    }
    
    private func parseMultiLabelOutput(_ output: String) -> String {
        // Handle multi-label outputs like "joy,excitement,love" or "approval,gratitude"
        let emotions = output.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Priority order for selecting primary emotion (positive emotions first)
        let emotionPriority: [String] = [
            "joy", "love", "excitement", "amusement", "gratitude", "pride", "optimism",
            "admiration", "approval", "caring", "relief", "desire",
            "anger", "sadness", "fear", "disgust", "disappointment", "annoyance",
            "embarrassment", "nervousness", "remorse", "grief", "disapproval",
            "surprise", "curiosity", "confusion", "realization", "neutral"
        ]
        
        // Find highest priority emotion in the output
        for priorityEmotion in emotionPriority {
            if emotions.contains(priorityEmotion) {
                return priorityEmotion
            }
        }
        
        // If no known emotion found, return the first one or neutral
        return emotions.first ?? "neutral"
    }
}
