//
//  CustomButton.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 20.01.2023.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(text: String, selector: Selector, target: Any) {
        self.init(frame: .zero)
        addTarget(target, action: selector, for: .touchUpInside)
        setTitle(text, for: .normal)
    }


    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = UIFont.ypMediumFont(size: 20)
        layer.cornerRadius = 15
        setTitleColor(.ypBlack, for: .normal)
        backgroundColor = .ypWhite
    }

}
