// Created by Grant Emerson on 5/7/20.

import UIKit

public class SamplePadGroupView: UIView {
    
    public typealias BendHandler = (_ sampleType: SampleType, _ index: Int, _ bendPercent: Double) -> ()
    public typealias SelectionHandler = (_ sampleType: SampleType, _ index: Int, _ isCurrentlyPressed: Bool) -> ()
    
    // MARK: Properties
    
    public let sampleType: SampleType
    
    private var selectedFilm: Film = .gulliversTravels
    
    private let selectionHandler: SelectionHandler
    private let bendHandler: BendHandler
    
    private var samplePadViews = [SamplePadView]()
    
    private lazy var samplePadHolderView: UIView = {
        let samplePadHolderView = UIView()
        
        for index in 0..<4 {
            let samplePadView = SamplePadView(index: index, selectionHandler: { [weak self] index, isCurrentlyPressed in
                guard let self = self else { return }
                self.selectionHandler(self.sampleType, index, isCurrentlyPressed)
            }, bendHandler: { [weak self] index, bend in
                guard let self = self else { return }
                self.bendHandler(self.sampleType, index, bend)
            })
            
            samplePadView.thumbnailImage = UIImage(named: "Thumbnails/\(selectedFilm.formattedName) \(sampleType.name) \(index + 1).jpeg")
            samplePadView.translatesAutoresizingMaskIntoConstraints = false
            
            samplePadViews.append(samplePadView)
            samplePadHolderView.add(samplePadView)
        }
        
        samplePadHolderView.translatesAutoresizingMaskIntoConstraints = false
        return samplePadHolderView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryTextColor
        label.font = UIFont(name: "Futura", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Init
    
    public init(sampleType: SampleType, selectionHandler: @escaping SelectionHandler, bendHandler: @escaping BendHandler) {
        self.sampleType = sampleType
        self.selectionHandler = selectionHandler
        self.bendHandler = bendHandler
        super.init(frame: .zero)
        setUpView()
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Methods
    
    private func setUpView() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = sampleType.name
    }
    
    private func setUpSubviews() {
        add(titleLabel, samplePadHolderView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            samplePadHolderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            samplePadHolderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            samplePadHolderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            samplePadHolderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            samplePadViews[0].leadingAnchor.constraint(equalTo: samplePadHolderView.leadingAnchor, constant: 5),
            samplePadViews[0].trailingAnchor.constraint(equalTo: samplePadHolderView.centerXAnchor, constant: -2.5),
            samplePadViews[0].topAnchor.constraint(equalTo: samplePadHolderView.topAnchor, constant: 5),
            samplePadViews[0].bottomAnchor.constraint(equalTo: samplePadHolderView.centerYAnchor, constant: -2.5),
            
            samplePadViews[1].leadingAnchor.constraint(equalTo: samplePadHolderView.centerXAnchor, constant: 2.5),
            samplePadViews[1].trailingAnchor.constraint(equalTo: samplePadHolderView.trailingAnchor, constant: -5),
            samplePadViews[1].topAnchor.constraint(equalTo: samplePadHolderView.topAnchor, constant: 5),
            samplePadViews[1].bottomAnchor.constraint(equalTo: samplePadHolderView.centerYAnchor, constant: -2.5),
            
            samplePadViews[2].leadingAnchor.constraint(equalTo: samplePadHolderView.leadingAnchor, constant: 5),
            samplePadViews[2].trailingAnchor.constraint(equalTo: samplePadHolderView.centerXAnchor, constant: -2.5),
            samplePadViews[2].topAnchor.constraint(equalTo: samplePadHolderView.centerYAnchor, constant: 2.5),
            samplePadViews[2].bottomAnchor.constraint(equalTo: samplePadHolderView.bottomAnchor, constant: -5),
            
            samplePadViews[3].leadingAnchor.constraint(equalTo: samplePadHolderView.centerXAnchor, constant: 2.5),
            samplePadViews[3].trailingAnchor.constraint(equalTo: samplePadHolderView.trailingAnchor, constant: -5),
            samplePadViews[3].topAnchor.constraint(equalTo: samplePadHolderView.centerYAnchor, constant: 2.5),
            samplePadViews[3].bottomAnchor.constraint(equalTo: samplePadHolderView.bottomAnchor, constant: -5)
        ])
    }
    
    // MARK: Public
    
    public func setFilm(_ film: Film) {
        selectedFilm = film
        for (index, samplePadView) in samplePadViews.enumerated() {
            samplePadView.thumbnailImage = UIImage(named: "Thumbnails/\(selectedFilm.formattedName) \(sampleType.name) \(index + 1).jpeg")
        }
    }
    
    public func getSamplePadView(at index: Int) -> UIView? {
        guard index < 4 else { return nil }
        return samplePadViews[index]
    }
}
