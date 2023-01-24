import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    //MARK: - Outlets
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!



    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenterProtocol?

    private var task: DispatchWorkItem?

    private let presenter = MovieQuizPresenter()


    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter.viewController = self
        alertPresenter?.delegate = self
        setupActivityIndicator()
        questionFactory?.loadData()

    }
    
    //MARK: - Private functions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    

    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .ypBlack
        activityIndicator.startAnimating() // включаем анимацию
    }

    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating() // скрываем индикатор загрузки

        let errorAlert = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }

            self.activityIndicator.startAnimating()
            self.questionFactory?.loadData()

        }

        alertPresenter?.show(model: errorAlert)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // делаем рамку зеленой или красной
        togglenteraction() //отключаем кнопки и затемняем
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.togglenteraction() // включаем кнопки и ставим альфу 1
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = .none
            
        }
    }
    private func togglenteraction() {
        self.noButton.isEnabled.toggle() // отключаем кнопки чтобы нельзя было выбирать во время задержки
        self.yesButton.isEnabled.toggle()
        self.yesButton.alpha = yesButton.isEnabled ? 1.0 : 0.8
        self.noButton.alpha = noButton.isEnabled ? 1.0 : 0.8
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        UIView.transition(with: imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = step.image},
                          completion: nil)
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

    }


    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService else { return }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)

            let totalAccuracyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
            let localizedTime = statisticService.bestGame.date.dateTimeString
            let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"

            let text =
            """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGameStats) (\(localizedTime))
            Средняя точность: \(totalAccuracyPercentage)
            """

            let alert = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз") { [weak self] in
                guard let self else { return }

                self.presenter.resetQuestionIndex() // сброс счета
                self.correctAnswers = 0

                self.questionFactory?.requestNextQuestion()  // заново показываем первый вопрос
            }

            alertPresenter?.show(model: alert)
        } else {
            task = DispatchWorkItem { self.activityIndicator.startAnimating() }
            // ставим таск на 0.3 секунды для показа спиннера загрузки, только в случае медленного соединия
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task!)

            presenter.switchToNextQuestion() // увеличиваем индекс текущего индекса на 1
            questionFactory?.requestNextQuestion()
        }
    }


    


    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        task?.cancel() //отменяем таск на показ спиннера

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            self.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: YPError) {
        showNetworkError(message: error.rawValue)
    }
}






