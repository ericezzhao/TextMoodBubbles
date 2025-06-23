import Foundation
import CreateML
import CoreML

// MARK: - Emotion Classification Model Training
// This Swift code trains the emotion classification model using MLTextClassifier

func trainEmotionClassificationModel() {
    print("=== Phase 2: ML Model Training Started ===")
    
    // Step 1: Load the training data (Playground version)
    print("Loading training data...")
    
    // For Playgrounds, try to find the file in Resources or use absolute path
    var dataURL: URL?
    
    // Method 1: Try Playground Resources folder
    if let resourceURL = Bundle.main.url(forResource: "goemotions_text_label", withExtension: "csv") {
        dataURL = resourceURL
        print("Found data file in Playground Resources: \(resourceURL.path)")
    }
    // Method 2: Try absolute path (you'll need to update this path)
    else {
        print("File not found in Resources. Please either:")
        print("1. Add goemotions_text_label.csv to your Playground's Resources folder, OR")
        print("2. Update the absolutePath below with the full path to your CSV file")
        
        // UPDATE THIS PATH with your actual file location
        let absolutePath = "/Users/YOUR_USERNAME/path/to/bubble-text-app/data/goemotions_text_label.csv"
        let absoluteURL = URL(fileURLWithPath: absolutePath)
        
        if FileManager.default.fileExists(atPath: absolutePath) {
            dataURL = absoluteURL
            print("Found data file at absolute path: \(absolutePath)")
        } else {
            print("File not found at: \(absolutePath)")
            print("Please update the absolutePath variable with the correct path to your CSV file")
        }
    }
    
    guard let finalDataURL = dataURL else {
        print("ERROR: Could not find goemotions_text_label.csv")
        print("\nPlayground Setup Instructions:")
        print("1. EASY WAY: Copy goemotions_text_label.csv to your Playground's Resources folder")
        print("2. ALTERNATIVE: Update the absolutePath variable above with your file's full path")
        return
    }
    
          do {
        // Load CSV data for training using MLDataTable directly
        let dataTable = try MLDataTable(contentsOf: finalDataURL)
        print("Training data loaded successfully")
        print("Data shape: \(dataTable.rows.count) rows, \(dataTable.columnNames.count) columns")
        print("Columns: \(dataTable.columnNames)")
        
        // Step 2: Split data into train/test (80/20) - MLTextClassifier handles internal validation
        print("\nSplitting data: 80% training, 20% test...")
        let (trainingData, testData) = dataTable.randomSplit(by: 0.8, seed: 42)
        
        print("Training samples: \(trainingData.rows.count)")
        print("Test samples: \(testData.rows.count)")
        print("Note: MLTextClassifier will automatically create validation split from training data")
        
        // Step 3: Create the text classifier (will auto-split training data for validation)
        print("\nCreating MLTextClassifier...")
        let textClassifier = try MLTextClassifier(trainingData: trainingData,
                                                textColumn: "text",
                                                labelColumn: "label")
        
        // Step 4: Print training and validation metrics
        print("\nTraining completed!")
        print("Training accuracy: \(1.0 - textClassifier.trainingMetrics.classificationError)")
        print("Validation accuracy: \(1.0 - textClassifier.validationMetrics.classificationError)")
        
        // Step 5: Evaluate on test set
        print("\nEvaluating on test set...")
        let testEvaluation = textClassifier.evaluation(on: testData, textColumn: "text", labelColumn: "label")
        print("Test accuracy: \(1.0 - testEvaluation.classificationError)")
        print("Test error: \(testEvaluation.classificationError)")
        
        // Step 6: Test the model with sample texts
        print("\nTesting model with sample texts...")
        let testTexts = [
            "I'm so happy today!",
            "This is really annoying me",
            "I'm feeling sad about this",
            "That's absolutely amazing!",
            "I'm not sure what to think",
            "This makes me angry",
            "I love this so much",
            "I'm worried about tomorrow"
        ]
        
        for text in testTexts {
            let prediction = try textClassifier.prediction(from: text)
            print("Text: '\(text)' -> Emotion: \(prediction)")
        }
        
        // Step 7: Save the trained model
        print("\nSaving trained model...")
        // For Playground, save to Desktop or a known location
        let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
        let modelURL = URL(fileURLWithPath: desktopPath).appendingPathComponent("EmotionClassifier.mlmodel")
        try textClassifier.write(to: modelURL)
        print("Model saved to Desktop: \(modelURL.path)")
        
        // Step 8: Model metadata
        print("\nModel Information:")
        print("- Input: Text (String)")
        print("- Output: Emotion label (String)")
        print("- Total emotions: 28 categories")
        print("- Training samples: ~207,814")
        
        print("\n=== Phase 2: ML Model Training Complete! ===")
        
    } catch {
        print("Error during training: \(error)")
    }
}

// Run the training
trainEmotionClassificationModel()
