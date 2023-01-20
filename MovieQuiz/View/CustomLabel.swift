//
//  CustomLabel.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 20.01.2023.
//

import UIKit


class CustomLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(text: String, font: UIFont, numberOfLines: Int = 1) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.numberOfLines = numberOfLines
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .ypWhite
    }
}
