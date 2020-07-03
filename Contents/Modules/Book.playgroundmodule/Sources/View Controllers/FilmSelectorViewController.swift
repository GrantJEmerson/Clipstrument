// Created by Grant Emerson on 5/10/20.

import UIKit

public protocol FilmSelectorVCDelegate: AnyObject {
    func filmSelectorVC(_ filmSelectorVC: FilmSelectorViewController, didSelect film: Film)
}

public class FilmSelectorViewController: UIViewController {
    
    // MARK: Properties
    
    public weak var delegate: FilmSelectorVCDelegate?
    
    public private(set) var selectedFilm: Film = .gulliversTravels {
        didSet {
            selectedFilmLabel.text = "Selected Film: \(selectedFilm.name)"
            delegate?.filmSelectorVC(self, didSelect: selectedFilm)
        }
    }
    
    private lazy var selectedFilmLabel: UILabel = {
        let selectedFilmLabel = UILabel()
        selectedFilmLabel.textColor = .primaryTextColor
        selectedFilmLabel.font = UIFont(name: "Futura", size: 15)
        selectedFilmLabel.text = "Selected Film: \(selectedFilm.name)"
        return selectedFilmLabel
    }()
    
    private lazy var leftArrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .interactive
        button.isEnabled = false
        button.backgroundColor = .tertiaryBackground
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(selectPreviousFilm), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .interactive
        button.backgroundColor = .tertiaryBackground
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(selectNextFilm), for: .touchUpInside)
        return button
    }()
    
    private lazy var navigationButtonStackView = ButtonStackView([leftArrowButton, rightArrowButton],
                                                                 buttonSize: CGSize(width: 50, height: 50))
    
    private lazy var filmSelectorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [selectedFilmLabel, navigationButtonStackView])
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: View Controller Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }

    // MARK: Selector Methods
    
    @objc private func selectPreviousFilm() {
        let newIndex = selectedFilm.rawValue - 1
        guard selectedFilm.rawValue >= 0 else { return }
        selectedFilm = Film(rawValue: newIndex)!
        leftArrowButton.isEnabled = newIndex > 0
        rightArrowButton.isEnabled = true
    }
    
    @objc private func selectNextFilm() {
        let newIndex = selectedFilm.rawValue + 1
        guard newIndex < Film.all.count else { return }
        selectedFilm = Film(rawValue: newIndex)!
        rightArrowButton.isEnabled = newIndex < Film.all.count - 1
        leftArrowButton.isEnabled = true
    }
    
    // MARK: Private Methods
    
    private func setUpSubviews() {
        view.add(filmSelectorStackView)
        filmSelectorStackView.constrainToEdges()
    }
}
