// Created by Grant Emerson on 5/7/20.

import UIKit

public class MainViewController: UIViewController {
    
    // MARK: Properties
    
    private var hasCompletedTutorial = false
    
    private let sampler = Sampler()
    
    private lazy var controlBarView: UIView = {
        let controlBarView = UIView()
        controlBarView.backgroundColor = .secondaryBackground
        controlBarView.translatesAutoresizingMaskIntoConstraints = false
        return controlBarView
    }()
    
    private lazy var controlBarStackView: UIStackView = {
        let controlBarStackView = UIStackView()
        controlBarStackView.axis = .horizontal
        controlBarStackView.spacing = 20
        controlBarStackView.alignment = .center
        controlBarStackView.distribution = .fillProportionally
        controlBarStackView.translatesAutoresizingMaskIntoConstraints = false
        return controlBarStackView
    }()
    
    private lazy var controlsView: UIView = {
        let controlsView = UIView()
        controlsView.backgroundColor = .primaryBackground
        controlsView.layer.borderWidth = 3
        controlsView.layer.borderColor = UIColor.secondaryBackground.cgColor
        controlsView.layer.cornerRadius = 10
        controlsView.clipsToBounds = true
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        return controlsView
    }()
    
    private lazy var recordingControlsVC: RecordingControlsViewController = {
        let recordingControlsVC = RecordingControlsViewController()
        recordingControlsVC.delegate = self
        return recordingControlsVC
    }()
    
    private lazy var filmSelectorVC: FilmSelectorViewController = {
        let filmSelectorVC = FilmSelectorViewController()
        filmSelectorVC.delegate = self
        return filmSelectorVC
    }()
    
    private lazy var samplePadVC: SamplePadViewController = {
        let samplePadVC = SamplePadViewController()
        samplePadVC.delegate = self
        samplePadVC.view.translatesAutoresizingMaskIntoConstraints = false
        return samplePadVC
    }()
    
    private lazy var videoViewController: VideoViewController = {
        let videoVC = VideoViewController()
        videoVC.view.translatesAutoresizingMaskIntoConstraints = false
        return videoVC
    }()
    
    private lazy var effectViewController: EffectsViewController = {
        let effectVC = EffectsViewController()
        effectVC.delegate = self
        effectVC.view.translatesAutoresizingMaskIntoConstraints = false
        return effectVC
    }()
    
    // MARK: View Controller Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpSubviews()
        setUpConstraints()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasCompletedTutorial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.samplePadVC.startTutorial()
                self.hasCompletedTutorial = true
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoViewController.redrawViews()
        effectViewController.redrawViews()
    }
    
    // MARK: Private Methods
    
    private func setUpView() {
        view.backgroundColor = .primaryBackground
        view.contentMode = .redraw
    }
    
    private func setUpSubviews() {
        view.add(controlsView, videoViewController.view, effectViewController.view)
        controlsView.add(samplePadVC.view, controlBarView)
        controlBarView.add(controlBarStackView)
        [filmSelectorVC.view, recordingControlsVC.view].forEach(controlBarStackView.addArrangedSubview)
        
        addChild(samplePadVC)
        addChild(recordingControlsVC)
        addChild(videoViewController)
        addChild(filmSelectorVC)
        addChild(effectViewController)
        
        samplePadVC.didMove(toParent: self)
        recordingControlsVC.didMove(toParent: self)
        videoViewController.didMove(toParent: self)
        filmSelectorVC.didMove(toParent: self)
        effectViewController.didMove(toParent: self)
    }
    
    private func setUpConstraints() {
        
        let controlsViewWidthConstraint = controlsView.widthAnchor.constraint(equalTo: controlsView.heightAnchor)
        controlsViewWidthConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            controlsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controlsViewWidthConstraint,
            
            controlBarView.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor),
            controlBarView.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor),
            controlBarView.topAnchor.constraint(equalTo: controlsView.topAnchor),
            controlBarView.heightAnchor.constraint(equalToConstant: 60),
            
            controlBarStackView.centerXAnchor.constraint(equalTo: controlBarView.centerXAnchor),
            controlBarStackView.topAnchor.constraint(equalTo: controlBarView.topAnchor, constant: 5),
            controlBarStackView.bottomAnchor.constraint(equalTo: controlBarView.bottomAnchor, constant: -5),

            samplePadVC.view.topAnchor.constraint(equalTo: controlBarView.bottomAnchor),
            samplePadVC.view.bottomAnchor.constraint(equalTo: controlsView.bottomAnchor),
            samplePadVC.view.centerXAnchor.constraint(equalTo: controlsView.centerXAnchor),
            samplePadVC.view.widthAnchor.constraint(equalTo: samplePadVC.view.heightAnchor, constant: -45),
            
            videoViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            videoViewController.view.leadingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: 10),
            videoViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            videoViewController.view.heightAnchor.constraint(equalTo: videoViewController.view.widthAnchor, multiplier: 1080 / 1436, constant: 30),
            
            effectViewController.view.leadingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: 10),
            effectViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            effectViewController.view.topAnchor.constraint(equalTo: videoViewController.view.bottomAnchor, constant: 10),
            effectViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

extension MainViewController: SamplePadVCDelegate {
    public func samplePadViewController(_ samplePadViewController: SamplePadViewController, didPress index: Int, with sampleType: SampleType) {
        sampler.play(sampleType, with: index)
        videoViewController.playVideoFor(sampleType, at: index)
    }
    
    public func samplePadViewController(_ samplePadViewController: SamplePadViewController, didRelease index: Int, with sampleType: SampleType) {
        sampler.stop(sampleType, with: index)
        videoViewController.stopVideoFor(sampleType, at: index)
    }
    
    public func samplePadViewController(_ samplePadViewController: SamplePadViewController, didSetBendAt index: Int, with sampleType: SampleType, to bend: Double) {
        sampler.setPitchBendTo(Float(bend), for: sampleType, at: index)
    }
}

extension MainViewController: RecordingControlsVCDelegate {
    public func recordingControlsVC(_ recordingControlsVC: RecordingControlsViewController, didSetStateTo state: RecordingState) {
        switch state {
        case .recording:
            if !sampler.audioFileIsEmpty {
                sampler.startAudioPlayback()
            }
            sampler.startRecording()
        case .stopped:
            if sampler.isRecording {
                sampler.stopRecording()
            }
            sampler.stopAudioPlayback()
        case .playing:
            sampler.startAudioPlayback()
        }
    }
    
    public func recordingControlsVCDidSelectClear() {
        sampler.clearAudioRecording()
    }
}

extension MainViewController: FilmSelectorVCDelegate {
    public func filmSelectorVC(_ filmSelectorVC: FilmSelectorViewController, didSelect film: Film) {
        sampler.selectedFilm = film
        videoViewController.selectedFilm = film
        samplePadVC.selectedFilm = film
    }
}

extension MainViewController: EffectsVCDelegate {
    public func effectsVC(_ effectsVC: EffectsViewController, didUpdateWithEffectValue effectValue: Sampler.AudioEffectValue) {
        sampler.setAudioEffectValue(effectValue)
    }
}
