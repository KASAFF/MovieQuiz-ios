//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 24.01.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private let questionsAmount = 10

    var cancelIndicatorTask: DispatchWorkItem?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.setupActivityIndicator()
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()

        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"

        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }

    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: self.questionsAmount)

        let totalAccuracyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
        let localizedTime = statisticService.bestGame.date.dateTimeString
        let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"

        let resultMessage =
        """
        Ваш результат: \(correctAnswers)/\(self.questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGameStats) (\(localizedTime))
        Средняя точность: \(totalAccuracyPercentage)
        """

        return resultMessage
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect) //отключаем кнопки и затемняем
        viewController?.togglenteraction()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.viewController?.togglenteraction()
            self.proceedToNextQuestionOrResults()
        }
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()

    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }


    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showEndGameAlert()
        } else {
            cancelIndicatorTask = DispatchWorkItem { self.viewController?.activityIndicator.startAnimating() }
            // ставим таск на 0.3 секунды для показа спиннера загрузки, только в случае медленного соединия
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: cancelIndicatorTask!)

            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }


    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == isYes)
        if currentQuestion.correctAnswer == isYes {
            correctAnswers += 1
        }
    }

    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        cancelIndicatorTask?.cancel() //отменяем таск на показ спиннера
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewController?.hideLoadingIndicator()
            self.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: YPError) {
        viewController?.showNetworkError(message: error.rawValue)
    }
}
