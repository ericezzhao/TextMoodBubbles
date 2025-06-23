def create_emotion_color_mapping():
    
    
    emotion_colors = {
        # POSITIVE EMOTIONS
        'joy': '#FFD700',           # Gold
        'love': '#FF69B4',          # Hot Pink
        'excitement': '#FF4500',    # Orange Red
        'amusement': '#32CD32',     # Lime Green
        'gratitude': '#DDA0DD',     # Plum
        'admiration': '#4169E1',    # Royal Blue
        'optimism': '#FFB347',      # Peach
        'pride': '#9370DB',         # Medium Purple
        'relief': '#98FB98',        # Pale Green
        
        # APPROVAL/CARING EMOTIONS
        'approval': '#87CEEB',      # Sky Blue
        'caring': '#F0E68C',        # Khaki
        
        # COGNITIVE EMOTIONS
        'curiosity': '#40E0D0',     # Turquoise
        'realization': '#DA70D6',   # Orchid
        'surprise': '#FFFF00',      # Yellow
        'confusion': '#D3D3D3',     # Light Gray
        
        # NEGATIVE EMOTIONS
        'anger': '#DC143C',         # Crimson
        'annoyance': '#FF6347',     # Tomato
        'disappointment': '#4682B4', # Steel Blue
        'disapproval': '#708090',   # Slate Gray
        'sadness': '#191970',       # Midnight Blue
        'grief': '#2F4F4F',         # Dark Slate Gray
        'fear': '#8B0000',          # Dark Red
        'nervousness': '#F4A460',   # Sandy Brown
        
        # COMPLEX EMOTIONS
        'disgust': '#556B2F',       # Dark Olive Green
        'embarrassment': '#CD5C5C', # Indian Red
        'remorse': '#800080',       # Purple
        'desire': '#FF1493',        # Deep Pink
        
        # NEUTRAL
        'neutral': '#C0C0C0',       # Silver
    }
    
    return emotion_colors

def save_emotion_color_mapping():
    import json
    
    emotion_colors = create_emotion_color_mapping()
    
    # Save as JSON for import into iOS (for iMessage)
    mapping_data = {
        'emotion_colors': emotion_colors,
        'total_emotions': len(emotion_colors),
    }
    
    with open('data/emotion_color_mapping.json', 'w') as f:
        json.dump(mapping_data, f, indent=2)
    
    # save as Python dict for ML training reference (for CreateML)
    with open('emotion_colors.py', 'w') as f:
        f.write(f"# Emotion-to-Color Mapping for GoEmotion Dataset\n")
        f.write(f"EMOTION_COLORS = {emotion_colors}\n\n")
        f.write(f"def get_emotion_color(emotion):\n")
        f.write(f"    \"\"\"Get hex color code for an emotion\"\"\"\n")
        f.write(f"    return EMOTION_COLORS.get(emotion, '#C0C0C0')  # Default to neutral silver\n")
    
    print("=== Emotion-Color Mapping Created ===")
    print(f"Total emotions mapped: {len(emotion_colors)}")
    print("Files created:")
    print("- data/emotion_color_mapping.json (for iOS integration)")
    print("- emotion_colors.py (for Python reference)")
    
    print("\n=== Color Mapping Preview ===")
    for emotion, color in emotion_colors.items():
        print(f"{emotion:>15}: {color}")
    
    return emotion_colors

if __name__ == "__main__":
    emotion_colors = save_emotion_color_mapping()
