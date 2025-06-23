#!/bin/bash

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ Error: This script requires macOS for Create ML"
    exit 1
fi

# Create data directory if it doesn't exist
mkdir -p data/full_dataset

# Check if GoEmotion dataset exists
if [ ! -d "data/full_dataset" ] || [ -z "$(ls -A data/full_dataset)" ]; then
    echo "⚠️  GoEmotion dataset not found in data/full_dataset/"
    echo "📥 Please ensure the 3 GoEmotion CSV files are in data/full_dataset/"
    echo "   Expected files: goemotions_1.csv, goemotions_2.csv, goemotions_3.csv"
    echo ""
    echo "🔗 Download from: https://github.com/google-research/google-research/tree/master/goemotions"
    exit 1
fi

echo "✅ GoEmotion dataset found"

echo ""
echo "🔄 Processing GoEmotion Dataset"

if [ ! -f "data_processor.py" ]; then
    echo "❌ data_processor.py not found!"
    exit 1
fi

echo "🐍 Running data processing..."
python3 data_processor.py

if [ $? -ne 0 ]; then
    echo "❌ Data processing failed!"
    exit 1
fi

if [ ! -f "data/goemotions_text_label.csv" ]; then
    echo "❌ Processed dataset not generated!"
    exit 1
fi

echo "✅ Multilabel dataset ready"

echo ""
echo "🤖 Training CoreML Model"

if [ ! -f "train_model.swift" ]; then
    echo "❌ train_model.swift not found!"
    exit 1
fi

echo "🚀 Starting Create ML training..."
swift train_model.swift

if [ $? -ne 0 ]; then
    echo "❌ Model training failed!"
    exit 1
fi

if [ ! -f "EmotionClassifier.mlmodel" ]; then
    echo "❌ Model file not generated!"
    exit 1
fi

echo "✅ CoreML model trained"

echo ""
echo "🎉 Training Pipeline Complete!"

MODEL_SIZE=$(du -h EmotionClassifier.mlmodel | cut -f1)
DATASET_SIZE=$(wc -l < data/goemotions_text_label.csv)

echo "📊 Final Results:"
echo "  📁 Processed Dataset: data/goemotions_text_label.csv ($DATASET_SIZE samples)"
echo "  🤖 Trained Model: EmotionClassifier.mlmodel ($MODEL_SIZE)"
echo "  🎯 Model Type: MLTextClassifier (multilabel emotion classification)"
echo ""

echo "✨ Model training complete!"
