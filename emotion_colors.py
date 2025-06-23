# Emotion-to-Color Mapping for GoEmotion Dataset

EMOTION_COLORS = {'joy': '#FFD700', 'love': '#FF69B4', 'excitement': '#FF4500', 'amusement': '#32CD32', 'gratitude': '#DDA0DD', 'admiration': '#4169E1', 'optimism': '#FFB347', 'pride': '#9370DB', 'relief': '#98FB98', 'approval': '#87CEEB', 'caring': '#F0E68C', 'curiosity': '#40E0D0', 'realization': '#DA70D6', 'surprise': '#FFFF00', 'confusion': '#D3D3D3', 'anger': '#DC143C', 'annoyance': '#FF6347', 'disappointment': '#4682B4', 'disapproval': '#708090', 'sadness': '#191970', 'grief': '#2F4F4F', 'fear': '#8B0000', 'nervousness': '#F4A460', 'disgust': '#556B2F', 'embarrassment': '#CD5C5C', 'remorse': '#800080', 'desire': '#FF1493', 'neutral': '#C0C0C0'}

def get_emotion_color(emotion):
    """Get hex color code for an emotion"""
    return EMOTION_COLORS.get(emotion, '#C0C0C0')  # Default to neutral silver
