#!/usr/bin/env swift

import Foundation
import CreateML

// MARK: - Configuration
let projectName = "EmotionClassifier"
let inputDataPath = "data/goemotions_text_label.csv"
let outputModelPath = "EmotionClassifier.mlmodel"
// 80% training, 20% testing
let testSplit = 0.2
print("📁 Project: \(projectName)")
print("📊 Data: \(inputDataPath)")
print("💾 Output: \(outputModelPath)")

// MARK: - Primary Emotion Selection
func extractPrimaryEmotion(from multiLabel: String) -> String {
    let emotions = multiLabel.components(separatedBy: ",").map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Priority order for selecting primary emotion
    let emotionPriority: [String] = [
        "joy", "love", "excitement", "amusement", "gratitude", "pride", "optimism",
        "admiration", "approval", "caring", "relief", "desire",
        "anger", "sadness", "fear", "disgust", "disappointment", "annoyance",
        "embarrassment", "nervousness", "remorse", "grief", "disapproval",
        "surprise", "curiosity", "confusion", "realization", "neutral"
    ]
    
    // Find the highest priority emotion
    for priorityEmotion in emotionPriority {
        if emotions.contains(priorityEmotion) {
            return priorityEmotion
        }
    }
    
    // If no known emotion found, return the first one or neutral
    return emotions.first ?? "neutral"
}

// MARK: - Data Loading and Processing
print("\n📖 Loading and processing training data...")

do {
    // Load the multilabel dataset
    let originalData = try MLDataTable(contentsOf: URL(fileURLWithPath: inputDataPath))
    
    print("✅ Original data loaded!")
    print("📏 Original shape: \(originalData.rows.count) rows, \(originalData.columnNames.count) columns")
    
    // Process data to extract primary emotions
    print("\n🔄 Converting multi-label to single-label...")
    
    var textArray: [String] = []
    var labelArray: [String] = []
    var emotionCounts: [String: Int] = [:]
    
    for (index, row) in originalData.rows.enumerated() {
        if index % 5000 == 0 {
            print("  Processed \(index)/\(originalData.rows.count) samples...")
        }
        
        guard let text = row["text"]?.stringValue,
              let multiLabel = row["label"]?.stringValue else {
            continue
        }
        
        // Extract primary emotion
        let primaryEmotion = extractPrimaryEmotion(from: multiLabel)
        
        // Count emotions for statistics
        emotionCounts[primaryEmotion, default: 0] += 1
        
        // Add to arrays
        textArray.append(text)
        labelArray.append(primaryEmotion)
    }
    
    // Create new MLDataTable with single emotions
    let processedData = try MLDataTable(dictionary: [
        "text": textArray,
        "label": labelArray
    ])
    
    print("✅ Data processing completed!")
    print("📊 Final dataset: \(processedData.rows.count) samples")
    print("🏷️  Unique emotions: \(emotionCounts.keys.count)")
    
    // Show emotion distribution
    print("\n Emotion Distribution (Top 10):")
    let sortedEmotions = emotionCounts.sorted { $0.value > $1.value }
    for (emotion, count) in sortedEmotions.prefix(10) {
        let percentage = Double(count) / Double(processedData.rows.count) * 100
        print("  \(emotion): \(count) samples (\(String(format: "%.1f", percentage))%)")
    }
    
    // Show sample data
    print("\n📝 Sample processed data:")
    for i in 0..<min(5, processedData.rows.count) {
        let row = processedData.rows[i]
        let text = row["text"]?.stringValue ?? "N/A"
        let label = row["label"]?.stringValue ?? "N/A"
        print("  \"\(String(text.prefix(40)))...\" → \(label)")
    }
    
    // MARK: - Data Splitting
    print("\n🔀 Splitting data for training/test...")
    
    let (trainingData, testingData) = processedData.randomSplit(by: 1.0 - testSplit, seed: 42)
    
    print("📊 Data split:")
    print("  🏋️ Training: \(trainingData.rows.count) samples")
    print("  🧪 Testing: \(testingData.rows.count) samples")
    
    // MARK: - Model Training
    print("\n🤖 Training MLTextClassifier model...")
    
    let startTime = Date()
    
    let classifier = try MLTextClassifier(
        trainingData: trainingData,
        textColumn: "text",
        labelColumn: "label"
    )
    
    let trainingTime = Date().timeIntervalSince(startTime)
    print("✅ Model training completed in \(String(format: "%.1f", trainingTime)) seconds!")
    
    // ------------------------------------------------------------
    // 🔍 Extra metrics: precision / recall / F1  (per class + macro + micro)
    // ------------------------------------------------------------
    print("\n📐 Computing precision / recall / F1 ...")

    // Containers
    var tp = [String: Int](), fp = [String: Int](), fn = [String: Int]()

    for row in testingData.rows {
        guard let text = row["text"]?.stringValue,
            let trueLabel = row["label"]?.stringValue else { continue }

        let predicted = try classifier.prediction(from: text)

        if predicted == trueLabel {
            tp[trueLabel, default: 0] += 1
        } else {
            fp[predicted, default: 0] += 1
            fn[trueLabel,    default: 0] += 1
        }
    }

    // Helper to get counts safely
    func val(_ dict: [String:Int], _ key: String) -> Double {
        return Double(dict[key] ?? 0)
    }

    var macroP = 0.0, macroR = 0.0, macroF1 = 0.0, classCount = 0
    var globalTP = 0.0, globalFP = 0.0, globalFN = 0.0

    print("\n🎯 Per-class metrics (precision / recall / F1):")
    for label in Set(tp.keys).union(fp.keys).union(fn.keys) {
        let TP = val(tp, label), FP = val(fp, label), FN = val(fn, label)
        let precision = TP / max(1, TP + FP)
        let recall    = TP / max(1, TP + FN)
        let f1        = (precision + recall) > 0 ? 2 * precision * recall / (precision + recall) : 0

        print(String(format: "  %-12s  P: %.3f  R: %.3f  F1: %.3f",
                    label, precision, recall, f1))

        macroP += precision; macroR += recall; macroF1 += f1; classCount += 1
        globalTP += TP; globalFP += FP; globalFN += FN
    }

    // Macro-average (simple mean across labels that appeared)
    macroP  /= classCount;  macroR  /= classCount;  macroF1 /= classCount

    // Micro-average (global TP / FP / FN)
    let microPrecision = globalTP / max(1, globalTP + globalFP)
    let microRecall    = globalTP / max(1, globalTP + globalFN)
    let microF1        = (microPrecision + microRecall) > 0 ?
                        2 * microPrecision * microRecall / (microPrecision + microRecall) : 0

    print("\n📊 Macro-average   P: \(String(format: "%.3f", macroP))"
        + "  R: \(String(format: "%.3f", macroR))"
        + "  F1: \(String(format: "%.3f", macroF1))")

    print("📊 Micro-average   P: \(String(format: \"%.3f\", microPrecision))"
        + "  R: \(String(format: \"%.3f\", microRecall))"
        + "  F1: \(String(format: \"%.3f\", microF1))")
    
    // MARK: - Model Testing
    print("\n🧪 Testing model with sample predictions...")
    
    let testTexts = [
        "I am so happy and excited about this!",
        "This makes me really angry and frustrated",
        "I'm feeling sad and disappointed today",
        "What an amazing surprise! I love this!",
        "I'm nervous but curious about what happens",
        "This is confusing and I don't understand",
        "I feel grateful for all the help I received",
        "I'm neutral about this situation"
    ]
    
    for (index, text) in testTexts.enumerated() {
        let prediction = try classifier.prediction(from: text)
        print("  \(index + 1). \"\(text)\"")
        print("     → Predicted Emotion: \(prediction)")
    }
    
    // MARK: - Model Export
    print("\n💾 Saving trained model...")
    
    try classifier.write(to: URL(fileURLWithPath: outputModelPath))
    print("✅ Model saved successfully to: \(outputModelPath)")
    
    // MARK: - Model Info
    print("\n📋 Final Model Information:")
    print("  🏷️  Model Type: MLTextClassifier (Single Emotion)")
    print("  🎯 Expected Classes: ~\(emotionCounts.keys.count) emotions")
    print("  📊 Training Samples: \(trainingData.rows.count)")
    print("  🧪 Test Samples: \(testingData.rows.count)")
    print("  📈 Accuracy: \(String(format: "%.1f", accuracy * 100))%")
    
    // Check model file size
    let modelURL = URL(fileURLWithPath: outputModelPath)
    if let attributes = try? FileManager.default.attributesOfItem(atPath: modelURL.path),
       let fileSize = attributes[.size] as? NSNumber {
        let sizeInMB = Double(fileSize.intValue) / (1024 * 1024)
        print("  💾 Model Size: \(String(format: "%.1f", sizeInMB)) MB")
    }
    
    print("\n🎉 Model Training Complete!")
    
} catch {
    print("❌ Error during model training: \(error)")
    exit(1)
} 
