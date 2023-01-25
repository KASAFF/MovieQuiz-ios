//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Aleksey Kosov on 24.01.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()


        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        app.buttons["Yes"].tap()
        sleep(3)

        XCTAssertEqual(indexLabel.label, "2/10")

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        app.buttons["No"].tap()
        sleep(3)

        XCTAssertEqual(indexLabel.label, "2/10")

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testAlert() {
        sleep(3)
        for _ in (0...9) {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Game results"]

        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }

    func testAlertDismiss() {
        sleep(3)
        for _ in (0...9) {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Game results"]

        alert.buttons.firstMatch.tap()
        sleep(2)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
