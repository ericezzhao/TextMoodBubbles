import UIKit
import Messages

class BubbleRenderer {
    
    static func createBubbleSticker(text: String, emotion: String, size: CGSize = CGSize(width: 300, height: 150)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let bubbleRect = rect.insetBy(dx: 15, dy: 20)
            
            // iMessage bubble shape
            let bubblePath = createiMessageBubbleShape(in: bubbleRect, isMyMessage: true)
            
            // Get emotion color
            let baseColor = EmotionColors.shared.color(for: emotion)
            print("🎨 Creating bubble sticker for emotion: \(emotion), color: \(baseColor)")
            
            // shadow
            context.cgContext.saveGState()
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 2),
                blur: 8,
                color: UIColor.black.withAlphaComponent(0.12).cgColor
            )
            
            // Fill with solid color
            baseColor.setFill()
            bubblePath.fill()
            
            context.cgContext.restoreGState()
            
            // gradient
            drawCleanGradient(in: bubbleRect, baseColor: baseColor, context: context.cgContext, bubblePath: bubblePath)
            
            // text
            drawCleanText(text, in: bubbleRect, emotion: emotion, context: context.cgContext)
        }
    }
    
        private static func createiMessageBubbleShape(in rect: CGRect, isMyMessage: Bool) -> UIBezierPath {
        let width = rect.width
        let height = rect.height
        let x = rect.minX
        let y = rect.minY
        
        let bezierPath = UIBezierPath()
        
        if isMyMessage {
            // Right-aligned bubble (sent message), search up iMessage bubble design
            bezierPath.move(to: CGPoint(x: x + width - 20, y: y + height))
            bezierPath.addLine(to: CGPoint(x: x + 15, y: y + height))
            bezierPath.addCurve(to: CGPoint(x: x, y: y + height - 15),
                               controlPoint1: CGPoint(x: x + 8, y: y + height),
                               controlPoint2: CGPoint(x: x, y: y + height - 8))
            bezierPath.addLine(to: CGPoint(x: x, y: y + 15))
            bezierPath.addCurve(to: CGPoint(x: x + 15, y: y),
                               controlPoint1: CGPoint(x: x, y: y + 8),
                               controlPoint2: CGPoint(x: x + 8, y: y))
            bezierPath.addLine(to: CGPoint(x: x + width - 20, y: y))
            bezierPath.addCurve(to: CGPoint(x: x + width - 5, y: y + 15),
                               controlPoint1: CGPoint(x: x + width - 12, y: y),
                               controlPoint2: CGPoint(x: x + width - 5, y: y + 8))
            bezierPath.addLine(to: CGPoint(x: x + width - 5, y: y + height - 12))
            bezierPath.addCurve(to: CGPoint(x: x + width, y: y + height),
                               controlPoint1: CGPoint(x: x + width - 5, y: y + height - 1),
                               controlPoint2: CGPoint(x: x + width, y: y + height))
            bezierPath.addLine(to: CGPoint(x: x + width + 1, y: y + height))
            bezierPath.addCurve(to: CGPoint(x: x + width - 12, y: y + height - 4),
                               controlPoint1: CGPoint(x: x + width - 4, y: y + height + 1),
                               controlPoint2: CGPoint(x: x + width - 8, y: y + height - 1))
            bezierPath.addCurve(to: CGPoint(x: x + width - 20, y: y + height),
                               controlPoint1: CGPoint(x: x + width - 15, y: y + height),
                               controlPoint2: CGPoint(x: x + width - 20, y: y + height))
        }
        
        return bezierPath
    }

    private static func drawCleanGradient(in rect: CGRect, baseColor: UIColor, context: CGContext, bubblePath: UIBezierPath) {
        context.saveGState()
        
        let lighterColor = baseColor.withAlphaComponent(0.7)
        
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [lighterColor.cgColor, baseColor.cgColor] as CFArray,
            locations: [0.0, 1.0]
        ) else {
            context.restoreGState()
            return
        }
        
        // Clip to bubble shape
        bubblePath.addClip()

        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }

    private static func drawCleanText(_ text: String, in rect: CGRect, emotion: String, context: CGContext) {
        // padding
        let textRect = rect.insetBy(dx: 20, dy: 18)
        
        // text contrast
        let textColor = getContrastingTextColor(for: emotion)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: textColor,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                style.lineBreakMode = .byWordWrapping
                style.lineHeightMultiple = 1.12
                return style
            }()
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        // center text
        let textSize = attributedText.boundingRect(
            with: textRect.size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        let centeredRect = CGRect(
            x: textRect.minX,
            y: textRect.minY + (textRect.height - textSize.height) / 2,
            width: textRect.width,
            height: textSize.height
        )
        
        attributedText.draw(in: centeredRect)
    }
    
    // determines if white or black text
    private static func getContrastingTextColor(for emotion: String) -> UIColor {
        let bgColor = EmotionColors.shared.color(for: emotion)
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        bgColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5 ? UIColor.black : UIColor.white
    }
    

    
    // preview sticker
    static func createSimpleBubble(text: String, emotion: String) -> UIView {
        let bubbleView = UIView()
        bubbleView.backgroundColor = EmotionColors.shared.color(for: emotion)
        bubbleView.layer.cornerRadius = 20
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowOpacity = 0.3
        bubbleView.layer.shadowRadius = 4
        
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = getContrastingTextColor(for: emotion)
        label.numberOfLines = 0
        
        bubbleView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
        
        return bubbleView
    }
} 
