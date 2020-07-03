// Created by Grant Emerson on 5/9/20.

import UIKit
import AVFoundation

public class VideoViewController: UIViewController {
    
    // MARK: Properties
    
    public private(set) var loopingClips: [SampleType: [Int]] = {
        var loopingClips = [SampleType: [Int]]()
        for sampleType in SampleType.all {
            loopingClips[sampleType] = []
        }
        return loopingClips
    }() {
        didSet {
            updatePlayerLayerFrames()
        }
    }
    
    public var selectedFilm: Film = .gulliversTravels {
        didSet { loadVideosFor(selectedFilm) }
    }
    
    private var videos = [String: AVPlayerItem]()
    
    private lazy var videoPlayers: [SampleType: AVPlayer] = {
        var videoPlayers = [SampleType: AVPlayer]()
            
        for sampleType in SampleType.all {
            let videoPlayer = AVPlayer(playerItem: nil)
            videoPlayer.isMuted = true
            videoPlayers[sampleType] = videoPlayer
        }
        
        return videoPlayers
    }()
    
    private lazy var playerLayers: [AVPlayerLayer] = {
        var playerLayers = [AVPlayerLayer]()
        for sampleType in SampleType.all {
            let videoPlayer = videoPlayers[sampleType]
            let playerLayer = AVPlayerLayer(player: videoPlayer)
            playerLayer.cornerRadius = 10
            playerLayer.masksToBounds = true
            playerLayers.append(playerLayer)
        }
        return playerLayers
    }()
    
    private lazy var televisionView: UIView = {
        let tvView = TelevisionView()
        tvView.layer.cornerRadius = 20
        tvView.clipsToBounds = true
        tvView.contentMode = .redraw
        tvView.translatesAutoresizingMaskIntoConstraints = false
        return tvView
    }()
    
    private lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.layer.cornerRadius = 10
        videoView.clipsToBounds = true
        videoView.translatesAutoresizingMaskIntoConstraints = false
        return videoView
    }()
    
    // MARK: View Controller Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpSubviews()
        loadVideosFor(selectedFilm)
        setUpObservers()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpVideoLayers()
    }
    
    // MARK: Selector Methods
    
    @objc private func restartVideo() {
        for sampleType in SampleType.all {
            guard let player = videoPlayers[sampleType],
                let duration = player.currentItem?.duration,
                player.currentTime() == duration else { continue }
            player.seek(to: .zero)
            player.play()
        }
    }
    
    // MARK: Private Methods
    
    private func setUpView() {
        view.backgroundColor = .primaryBackground
    }
    
    private func setUpSubviews() {
        view.add(televisionView)
        televisionView.add(videoView)
        
        televisionView.constrainToEdges()
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: televisionView.leadingAnchor, constant: 20),
            videoView.trailingAnchor.constraint(equalTo: televisionView.trailingAnchor, constant: -20),
            videoView.topAnchor.constraint(equalTo: televisionView.topAnchor, constant: 20),
            videoView.bottomAnchor.constraint(equalTo: televisionView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setUpVideoLayers() {
        playerLayers.forEach(videoView.layer.addSublayer)
        updatePlayerLayerFrames()
    }
    
    private func updatePlayerLayerFrames() {
        let indexesActive = loopingClips.filter({ !$0.value.isEmpty }).map({ $0.key.rawValue })
        
        if indexesActive.count == 1 {
            let index = indexesActive[0]
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            playerLayers[index].frame = CGRect(origin: .zero, size: videoView.bounds.size)
            
            CATransaction.commit()
        } else if indexesActive.count > 1 {
            let layerWidth = videoView.bounds.width / 2
            let halfWidth = layerWidth / 2
            let layerHeight = videoView.bounds.height / 2
            let halfHeight = layerHeight / 2
            let layerSize = CGSize(width: layerWidth, height: layerHeight)
            
            var topCenter: CGPoint?
            var bottomCenter: CGPoint?
            var leftCenter: CGPoint?
            var rightCenter: CGPoint?
            
            if indexesActive.contains(0) && !indexesActive.contains(1) || indexesActive.contains(1) && !indexesActive.contains(0) {
                topCenter = CGPoint(x: videoView.bounds.midX - halfWidth, y: 0)
            }
            
            if indexesActive.contains(2) && !indexesActive.contains(3) || indexesActive.contains(3) && !indexesActive.contains(2) {
                bottomCenter = CGPoint(x: videoView.bounds.midX - halfWidth, y: videoView.bounds.midY)
            }
            
            if indexesActive.count < 3 {
                if indexesActive.contains(0) && !indexesActive.contains(2) || indexesActive.contains(2) && !indexesActive.contains(0) {
                    leftCenter = CGPoint(x: 0, y: videoView.bounds.midY - halfHeight)
                }
                
                if indexesActive.contains(1) && !indexesActive.contains(3) || indexesActive.contains(3) && !indexesActive.contains(1) {
                    rightCenter = CGPoint(x: videoView.bounds.midX, y: videoView.bounds.midY - halfHeight)
                }
            }
            
            playerLayers[0].frame = CGRect(origin: topCenter ?? leftCenter ?? CGPoint(x: 0, y: 0), size: layerSize)
            playerLayers[1].frame = CGRect(origin: topCenter ?? rightCenter ?? CGPoint(x: videoView.bounds.midX, y: 0), size: layerSize)
            playerLayers[2].frame = CGRect(origin: bottomCenter ?? leftCenter ?? CGPoint(x: 0, y: videoView.bounds.midY), size: layerSize)
            playerLayers[3].frame = CGRect(origin: bottomCenter ?? rightCenter ?? CGPoint(x: videoView.bounds.midX, y: videoView.bounds.midY), size: layerSize)
        }
    }
    
    private func loadVideosFor(_ film: Film) {
        videos.removeAll()
        
        guard let videoDirectoryURL = Bundle.main.url(forResource: "Films/\(film.formattedName)/Videos", withExtension: nil) else {
            preconditionFailure("Could not load video directory for film: \(film.formattedName)")
        }
        
        for sampleType in SampleType.all {
            for index in 0..<4 {
                let videoName = "\(sampleType.name) \(index + 1)"
                let videoURL = videoDirectoryURL.appendingPathComponent("\(videoName).mp4")
                videos[videoName] = AVPlayerItem(url: videoURL)
            }
        }
    }
    
    private func setUpObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    // MARK: Public Methods
    
    public func playVideoFor(_ sampleType: SampleType, at index: Int) {
        guard let videoPlayer = videoPlayers[sampleType] else { return }
                
        let video = videos["\(sampleType.name) \(index + 1)"]
        videoPlayer.replaceCurrentItem(with: video)
        videoPlayer.playImmediately(atRate: 1)
        
        loopingClips[sampleType]?.append(index)
    }
    
    public func stopVideoFor(_ sampleType: SampleType, at index: Int) {
        loopingClips[sampleType]?.removeAll(where: { $0 == index })
        videoPlayers[sampleType]?.pause()
        
        guard let clips = loopingClips[sampleType] else { return }

        if clips.isEmpty {
            videoPlayers[sampleType]?.replaceCurrentItem(with: nil)
        } else {
            playVideoFor(sampleType, at: clips.last!)
        }
    }
    
    public func redrawViews() {
        televisionView.setNeedsDisplay()
    }
}
