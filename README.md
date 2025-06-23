# 🍎 Text Reponsive Emotion Sticker - iOS iMessage Extension

Goemotions blog: https://research.google/blog/goemotions-a-dataset-for-fine-grained-emotion-classification/

iOS iMessage extension that automatically detects emotions bsaed on the text and creates a colored text bubbles based on the emotional content. Model is trained on the GoEmotion dataset consisting of 28 emotions.

## Video Demo


## ✨ Features

- **Real-time Emotion Detection**: Analyze text emotions as you type
- **28 Emotion Categories**: Comprehensive emotion recognition based on GoEmotion
- **Sticker Creation**: Convert emotional text into shareable iMessage stickers
- **85.4% Accuracy Model**: Emotion classification model using CoreML
- **CoreML Optimization**: 1.2 MB model optimized for iOS
- **GoEmotion Dataset**: Trained on 58,009 text samples with labled emotion
- **Messages Extension**: Seamless integration with iOS Messages app

## 🚀 Quick Start

### Installation
1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd emotion-text-bubble
   ```

2. **Open in Xcode**
   ```bash
   open emotion-text-bubble.xcodeproj
   ```

3. **Build and Run**
   - Select target device/simulator
   - Press ⌘R to build and run

### Testing the Messages Extension
1. Open Messages app in simulator
3. Tap the + icon bottom left of the message area
4. Scroll and select emotion-text-bubble app
5. Type your text in the input box to preview

## 🏗️ Project Architecture

### Core Components

```
emotion-text-bubble/
├── 📱 Main App
│   ├── AppDelegate.swift
│   ├── ViewController.swift
│   └── Main.storyboard
├── 💬 Messages Extension
│   ├── MessagesViewController.swift
│   ├── MainInterface.storyboard
│   └── Info.plist
└── 🔄 Shared Components
    ├── EmotionDetector.swift      # CoreML integration
    ├── EmotionColors.swift        # Emotion-color mapping
    ├── BubbleRenderer.swift       # Custom bubble graphics
    ├── EmotionClassifier.mlmodel  # Trained ML model
    └── emotion_color_mapping.json # Color configuration
```

### Classes

#### `EmotionDetector.swift`
- **Purpose**: CoreML model wrapper for emotion classification
- **Features**: Text preprocessing, model loading, prediction handling
- **Input**: Raw text string
- **Output**: Single emotion label (e.g., "joy", "anger", "excitement")

#### `EmotionColors.swift`
- **Purpose**: Maps emotions to appropriate colors
- **Features**: 28 emotion-color mappings, JSON configuration loading
- **Psychology**: Colors chosen based on GoEmotions mapping
- **Format**: Returns UIColor objects for iOS rendering

#### `BubbleRenderer.swift`
- **Purpose**: Creates iMessage-style text bubbles
- **Features**: Core Graphics rendering, gradients, shadows, proper geometry
- **Customization**: Emotion-based coloring, typography, bubble tails
- **Output**: UIImage suitable for sticker creation

#### `MessagesViewController.swift`
- **Purpose**: Main Messages extension interface
- **Features**: Real-time text analysis, sticker creation
- **User Flow**: Type text → See emotion → Preview bubble sticker → Share sticker

## 🔬 Data Analysis and Model Training

### Previously Conducted Analysis
https://github.com/tensorflow/models/blob/master/research/seq_flow_lite/demo/colab/emotion_colab.ipynb
https://github.com/google-research/google-research/tree/master/goemotions

### Project-Specific Processing
1. **GoEmotion Dataset**: 58,011 unique text samples with 28 possible emotion annotations curated comments extracted from Reddit. Total of 211,225 annotations from 82 different raters
2. **Multilabel Strategy**: Preserve all human rater judgments (min_votes=1)
3. **Format Conversion**: One-hot encoding → comma-separated labels to allow multiple emotions per data
4. **Color Mapping**: Colors were arbitrarily mapped but too many emotions led to overlap. Either stick to fewer emotions or have it dynamic based on intensity of emotion

### Model Training
1. **Framework**: CreateML's MLTextClassifier
2. **Approach**: Direct multilabel training for optimal performance
3. **Optimization**: Automatic multilabel→single-label conversion by MLTextClassifier
Most model training details are handled by CreateML framework and MLTextClassifier

### Results
- **Accuracy**: 85.4% in predicting text emotion
   - **Note**: If a text had multiple emotions from raters (ex. ['joy', 'excitement']) and the model predicts any one of those (either joy or excitement), it will be classified as correct. 
- **Model Ability**: 28-class emotion classification
- **Deployment**: Production-ready CoreML .mlmodel
- **Evaluation**: Traditionally, the evaluation penalized the model if it was unable to produce all the emotions in the predictions which led to abysmal accuracy. Instead, if the model predicted one out of the valid emotions from the raters, it would be correct.

## Reflection, Future Work, To Do
- Change the dataset I am using as 26 emotions led to many overlaps which may harm the model's ability to be robust. More data, less emotions or have another model that allows for dynamic color changing based on intensity
- As mentioned multiple times, the color gimmick could definetely improved since many emotions have overlapping colors or may not be reflective of what color is typically associated with that emotion
- Instead of using CreateML's built in model training features, train a new model such as PRADO or BERT and compare the performance. I had initially trained a PRADO model but was unable to convert the .keras model to a .mlmodel to be used by XCode
- Get better at using XCode since the majority of time was spent trying to connect the parts together to display the simulation
- Improve model robustness since it performs well for one-off comments as you would expect on Reddit but does not hold well for conversations or personalizatoin
- UI is not reflective of iMessage UI and text bubble
- Do my own data analysis to understand the potential biases in the dataset as well as compare my emotion ratings to the human anotator ratings
- Limitations in goemotions still persist
