#!/usr/bin/env python3
# converts multilabel dataset to single-label dataset because CreateML doesn't support multilabel (or I did it incorrectly)
import pandas as pd
import numpy as np
from collections import Counter
import random

def create_single_label_dataset():
    
    input_path = "data/goemotions_text_label.csv"
    output_path = "data/goemotions_single_label.csv"
    
    print(f"📖 Loading dataset: {input_path}")
    
    try:
        df = pd.read_csv(input_path)
        print(f"✅ Loaded {len(df)} samples")
        
        # Analyze distribution
        emotion_counts = Counter()
        multilabel_counts = Counter()
        
        for idx, row in df.iterrows():
            emotions = [e.strip() for e in row['label'].split(',')]
            multilabel_counts[len(emotions)] += 1
            for emotion in emotions:
                emotion_counts[emotion] += 1
        
        print(f"\n📊 Distribution:")
        for num_emotions, count in sorted(multilabel_counts.items()):
            percentage = count / len(df) * 100
            print(f"  {num_emotions} emotion(s): {count} texts ({percentage:.1f}%)")
        
        print(f"\n🎯 Top 10 Most Frequent Emotions:")
        for emotion, count in emotion_counts.most_common(10):
            percentage = count / sum(emotion_counts.values()) * 100
            print(f"  {emotion}: {count} occurrences ({percentage:.1f}%)")
        
        # Convert to single-label
        single_label_data = []
        strategy_counts = Counter()
        
        for idx, row in df.iterrows():
            text = row['text']
            emotions = [e.strip() for e in row['label'].split(',')]
            
            # Pick one emotion based on priority/frequency (otherwise the model concats multiple emotion as one)
            selected_emotion = select_single_emotion(emotions, emotion_counts)
            strategy_counts[f"{len(emotions)}_emotions"] += 1
            
            single_label_data.append({
                'text': text,
                'label': selected_emotion
            })
            
            if idx % 5000 == 0:
                print(f"  Processed {idx}/{len(df)} samples...")
        
        single_df = pd.DataFrame(single_label_data)
        
        print(f"📏 Original: {len(df)} multilabel samples")
        print(f"📏 Result: {len(single_df)} single-label samples")
        
        # new distribution
        new_emotion_counts = single_df['label'].value_counts()
        print(f"\n📊 Single-Label Emotion Distribution:")
        for emotion, count in new_emotion_counts.head(10).items():
            percentage = count / len(single_df) * 100
            print(f"  {emotion}: {count} samples ({percentage:.1f}%)")
        
        single_df.to_csv(output_path, index=False)
        print(f"\n💾 Saved new dataset to: {output_path}")
        print(f"  📊 Unique emotions (expect 28): {single_df['label'].nunique()}")        
        return single_df
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def select_single_emotion(emotions, emotion_counts):
    """Select single emotion from multiple emotions"""
    
    if len(emotions) == 1:
        return emotions[0]
    
    # Strategy 1: Avoid 'neutral' if other emotions exist
    non_neutral = [e for e in emotions if e != 'neutral']
    if non_neutral:
        emotions = non_neutral
    
    # Strategy 2: Pick most frequent emotion globally (helps with class balance)
    emotion_frequencies = [(emotion, emotion_counts[emotion]) for emotion in emotions]
    emotion_frequencies.sort(key=lambda x: x[1], reverse=True)
    
    # Strategy 3: Add some randomness to prevent over-concentration
    if len(emotion_frequencies) > 1:
        # 70% chance: pick most frequent
        # 30% chance: pick randomly from top 2
        if random.random() < 0.7:
            return emotion_frequencies[0][0]
        else:
            return random.choice(emotion_frequencies[:2])[0]
    else:
        return emotion_frequencies[0][0]

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    result = create_single_label_dataset()
    
    if result is not None:
        print("\n🎉 Single-Label Dataset Creation Complete!")
        print("🚀 Ready for CreateML training")
    else:
        print("\n❌ Dataset creation failed!") 
