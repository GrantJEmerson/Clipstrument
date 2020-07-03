// Created by Grant Emerson on 5/8/20.

import UIKit

public enum RecordingState {
    case recording, stopped, playing
}

public protocol RecordingControlsVCDelegate: AnyObject {
    func recordingControlsVC(_ recordingControlsVC: RecordingControlsViewController, didSetStateTo state: RecordingState)
    func recordingControlsVCDidSelectClear()
}

public class RecordingControlsViewController: UIViewController {
    
    // MARK: Properties
    
    public weak var delegate: RecordingControlsVCDelegate?
    
    private var state: RecordingState = .stopped {
        didSet {
            switch state {
            case .recording:
                recordingButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                playButton.isEnabled = false
                clearButton.isEnabled = false
            case .stopped:
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                recordingButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                playButton.isEnabled = true
                recordingButton.isEnabled = true
                clearButton.isEnabled = true
            case .playing:
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
            
            delegate?.recordingControlsVC(self, didSetStateTo: state)
        }
    }
    
    private lazy var recordingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .red
        button.backgroundColor = .tertiaryBackground
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .blue
        button.isEnabled = false
        button.backgroundColor = .tertiaryBackground
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.isEnabled = false
        button.backgroundColor = .tertiaryBackground
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(presentClearRecordingConfirmationAlert), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordingControlStackView = ButtonStackView([recordingButton, playButton, clearButton],
                                                                 buttonSize: CGSize(width: 50, height: 50))
    
    // MARK: View Controller Life Cycle

    public override func loadView() {
        super.loadView()
        view = recordingControlStackView
    }
    
    // MARK: Selector Methods
    
    @objc private func toggleRecording() {
        if state == .recording {
            state = .stopped
            state = .playing
        } else {
            if state == .playing {
                state = .stopped
            }
            state = .recording
        }
    }
    
    @objc private func togglePlayback() {
        if state == .playing {
            state = .stopped
        } else {
            state = .playing
        }
    }
    
    @objc private func presentClearRecordingConfirmationAlert() {
        let alertController = UIAlertController(title: "Clear Recording",
                                      message: "Are you sure you want to clear this recording? This action is permanent.",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let confirmationAction = UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.clearRecording()
        }
        alertController.addAction(confirmationAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func clearRecording() {
        state = .stopped
        playButton.isEnabled = false
        clearButton.isEnabled = false
        delegate?.recordingControlsVCDidSelectClear()
    }
}
