//
//  MovieQuizViewControllerTests.swift
//  MovieQuizViewControllerTests
//
//  Created by Aleksey Kosov on 25.01.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    func togglenteraction() {

    }

    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func setupActivityIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    var activityIndicator: UIActivityIndicatorView!
    
    func showNetworkError(message: String) {
        
    }
    
    func showEndGameAlert() {
        
    }
}

final class MovieQUizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerProtocolMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
