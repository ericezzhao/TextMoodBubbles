# CoreML Model Setup

## Required File: EmotionClassifier.mlmodel


1. Copy `EmotionClassifier.mlmodel` to the `Shared/` folder
2. In Xcode, add the model to both targets:
   - emotion-text-app (main app target)
   - emotion-text-app-MessagesExtension (extension target)

## Model Specifications
- **File name**: EmotionClassifier.mlmodel
- **Size**: ~1.2 MB
- **Input**: Text string
- **Output**: Single emotion label (28 possible emotions)

## Integration
Once added, the model will be automatically loaded by `EmotionDetector.swift` and used for real-time emotion classification in the Messages extension. 