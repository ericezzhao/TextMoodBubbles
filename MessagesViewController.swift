import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    private let emotionDetector = EmotionDetector()
    private var currentText: String = ""
    private var currentEmotion: String = "neutral"
    
    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var createStickerButton: UIButton!
    @IBOutlet weak var emotionConfidenceLabel: UILabel!
    
    // Programmatic UI elements
    private var mainStackView: UIStackView!
    private var inputStackView: UIStackView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔧 MessagesViewController viewDidLoad")
        setupMessagesExtension()
        setupSimpleUI()
        setupTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set preferred content size for Messages extension, not dynamic
        self.preferredContentSize = CGSize(width: 320, height: 280)
    }
    
    private func setupMessagesExtension() {
        // Configure for Messages extension
        view.backgroundColor = .systemBackground
        
        // Set initial presentation style
        if let conversation = activeConversation {
            requestPresentationStyle(.expanded)
        }
    }
    
    private func setupSimpleUI() {
        print("🔧 Setting up simple UI...")
        
        // Create main stack view
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        
        // Create input stack view for text input and emotion display
        inputStackView = UIStackView()
        inputStackView.axis = .vertical
        inputStackView.spacing = 8
        inputStackView.alignment = .fill
        
        // Create text view
        let programmaticTextView = UITextView()
        programmaticTextView.delegate = self
        programmaticTextView.font = UIFont.systemFont(ofSize: 16)
        programmaticTextView.layer.cornerRadius = 8
        programmaticTextView.layer.borderWidth = 1
        programmaticTextView.layer.borderColor = UIColor.systemGray4.cgColor
        programmaticTextView.text = "Type your message here..."
        programmaticTextView.textColor = .placeholderText
        
        // Create emotion label
        let programmaticEmotionLabel = UILabel()
        programmaticEmotionLabel.text = "Emotion: neutral"
        programmaticEmotionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        programmaticEmotionLabel.textAlignment = .center
        
        // Create button
        let programmaticButton = UIButton(type: .system)
        programmaticButton.setTitle("Create Bubble Sticker", for: .normal)
        programmaticButton.backgroundColor = .systemBlue
        programmaticButton.setTitleColor(.white, for: .normal)
        programmaticButton.layer.cornerRadius = 8
        programmaticButton.isEnabled = false
        programmaticButton.addTarget(self, action: #selector(createStickerTapped), for: .touchUpInside)
        
        // Add to input stack
        inputStackView.addArrangedSubview(programmaticTextView)
        inputStackView.addArrangedSubview(programmaticEmotionLabel)
        
        // Add to main stack
        mainStackView.addArrangedSubview(inputStackView)
        mainStackView.addArrangedSubview(programmaticButton)
        
        // Add to main view
        view.addSubview(mainStackView)
        
        // Set up constraints with lower priority to avoid conflicts
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        programmaticTextView.translatesAutoresizingMaskIntoConstraints = false
        programmaticButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create constraints with priority lower than required to avoid conflicts
        let topConstraint = mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        let leadingConstraint = mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        let trailingConstraint = mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        let bottomConstraint = mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        let textHeightConstraint = programmaticTextView.heightAnchor.constraint(equalToConstant: 80)
        let buttonHeightConstraint = programmaticButton.heightAnchor.constraint(equalToConstant: 44)
        
        // Set priorities to avoid conflicts
        topConstraint.priority = UILayoutPriority(999)
        leadingConstraint.priority = UILayoutPriority(999)
        trailingConstraint.priority = UILayoutPriority(999)
        bottomConstraint.priority = UILayoutPriority(999)
        textHeightConstraint.priority = UILayoutPriority(999)
        buttonHeightConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            topConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint,
            textHeightConstraint,
            buttonHeightConstraint
        ])
        
        // Assign to outlets for compatibility
        textView = programmaticTextView
        emotionLabel = programmaticEmotionLabel
        createStickerButton = programmaticButton
    }
    
        private func setupTextView() {
        // Text view is already configured in setupSimpleUI()
        print("🔧 Text view setup completed. Delegate: \(textView?.delegate != nil ? "✅" : "❌")")
    }
    
    // MARK: - Actions
    @IBAction func createStickerTapped(_ sender: UIButton) {
        createBubbleSticker()
    }
    
    // MARK: - Emotion Detection
    private func detectEmotion(from text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            currentEmotion = "neutral"
            updateEmotionDisplay()
            return
        }
        
        // Detect emotion with confidence
        let result = emotionDetector.detectEmotionWithConfidence(from: text)
        currentEmotion = result.emotion
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.updateEmotionDisplay(confidence: result.confidence)
        }
    }
    
    private func updateEmotionDisplay(confidence: Double? = nil) {
        emotionLabel?.text = "Emotion: \(currentEmotion.capitalized)"
        emotionLabel?.textColor = EmotionColors.shared.color(for: currentEmotion)
        
        if let confidence = confidence {
            emotionConfidenceLabel?.text = "Confidence: \(Int(confidence * 100))%"
        } else {
            emotionConfidenceLabel?.text = "Confidence: -"
        }
    }
    

    
    // MARK: - Sticker Creation
    private func createBubbleSticker() {
        guard !currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "Empty Message", message: "Please enter some text to create a bubble sticker.")
            return
        }
        
        // Create the bubble sticker image
        guard let stickerImage = BubbleRenderer.createBubbleSticker(
            text: currentText,
            emotion: currentEmotion,
            size: CGSize(width: 300, height: 150)
        ) else {
            showAlert(title: "Error", message: "Failed to create bubble sticker.")
            return
        }
        
        // Create MSSticker
        do {
            // Save the image temporarily
            let tempURL = createTempImageFile(image: stickerImage)
            let sticker = try MSSticker(contentsOfFileURL: tempURL, localizedDescription: "Emotion bubble: \(currentEmotion)")
            
            // Insert the sticker into the conversation
            insertSticker(sticker)
            
            // Provide feedback
            showSuccessAnimation()
            
        } catch {
            showAlert(title: "Error", message: "Failed to create sticker: \(error.localizedDescription)")
        }
    }
    
    private func createTempImageFile(image: UIImage) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "bubble_\(UUID().uuidString).png"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
        
        return fileURL
    }
    
    private func insertSticker(_ sticker: MSSticker) {
        // Insert sticker into the conversation
        activeConversation?.insert(sticker) { error in
            if let error = error {
                print("Failed to insert sticker: \(error)")
            } else {
                print("✅ Sticker inserted successfully!")
            }
        }
    }
    
    private func showSuccessAnimation() {
        createStickerButton?.backgroundColor = .systemGreen
        createStickerButton?.setTitle("✓ Sticker Created!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.createStickerButton?.backgroundColor = .systemBlue
            self.createStickerButton?.setTitle("Create Bubble Sticker", for: .normal)
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Messages App Lifecycle
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        // App became active
    }
    
    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
        // App resigned active
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        super.didReceive(message, conversation: conversation)
        // Handle received message if needed
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        super.didStartSending(message, conversation: conversation)
        // Handle message sending started
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        super.didCancelSending(message, conversation: conversation)
        // Handle message sending cancelled
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        // Handle presentation style changes
    }
}

// MARK: - UITextView Delegate
extension MessagesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Type your message here..."
            textView.textColor = .placeholderText
            currentText = ""
            createStickerButton?.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentText = text
        
        print("🔧 Text changed: '\(text)'")
        
        // Enable/disable create button
        createStickerButton?.isEnabled = !text.isEmpty
        print("🔧 Button enabled: \(!text.isEmpty)")
        
        // Detect emotion with slight delay to avoid too frequent calls
        NSObject.cancelPreviousPerformRequests(target: self, selector: #selector(performEmotionDetection), object: nil)
        perform(#selector(performEmotionDetection), with: nil, afterDelay: 0.5)
    }
    
    @objc private func performEmotionDetection() {
        detectEmotion(from: currentText)
    }
} 