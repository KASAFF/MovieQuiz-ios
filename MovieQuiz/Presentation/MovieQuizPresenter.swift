//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 24.01.2023.
//

import UIKit

final class MovieQuizPresenter {

    let questionsAmount = 10
    private var currentQuestionIndex = 0

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }


    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()

        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"

        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }
}
