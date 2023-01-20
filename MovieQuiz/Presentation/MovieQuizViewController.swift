import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    //MARK: - Outlets

    lazy private var yesButton = CustomButton(text: "Да", selector: #selector(yesButtonClicked), target: self)
    lazy private var noButton = CustomButton(text: "Нет", selector: #selector(noButtonClicked), target: self)

    private let questionLabel = CustomLabel(text: "Вопрос:", font: .ypMediumFont(size: 20))

    private let counterLabel = CustomLabel(text: "1/10", font: .ypMediumFont(size: 20))


    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let textLabel: CustomLabel = {
        let label = CustomLabel(text: "Рейтинг этого фильма больше чем 7?",
                                font: .ypBoldFont(size: 23),
                                numberOfLines: 2)
        label.textAlignment = .center
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        aiv.color = .ypWhite
        return aiv
    }()

    private var currentQuestionIndex = 0
    
    private let questionsAmount = 10
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenterProtocol?

    private var task: DispatchWorkItem?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupLayout()
        activityIndicator.startAnimating()
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter?.delegate = self
        activityIndicator.startAnimating()
        questionFactory?.loadData()
    }
    
    //MARK: - Private functions
    
    @objc private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @objc private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
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
    
    private func showAnswerResult(isCorrect: Bool) {
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
        if currentQuestionIndex == self.questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let totalAccuracyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
            let localizedTime = statisticService.bestGame.date.dateTimeString
            let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"

            let text =
            """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGameStats) (\(localizedTime))
            Средняя точность: \(totalAccuracyPercentage)
            """

            let alert = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз") { [weak self] in
                guard let self = self else { return }

                self.currentQuestionIndex = 0 // сброс счета
                self.correctAnswers = 0

                self.questionFactory?.requestNextQuestion()  // заново показываем первый вопрос
            }

            alertPresenter?.show(model: alert)
        } else {
            task = DispatchWorkItem { self.activityIndicator.startAnimating() }
            // ставим таск на 0.3 секунды для показа спиннера загрузки, только в случае медленного соединия
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task!)

            currentQuestionIndex += 1 // увеличиваем индекс текущего урока на 1
            questionFactory?.requestNextQuestion()
        }
    }


    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()

        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"

        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }

    //MARK: - Layout

    private func configureTopStackView() -> UIStackView {
        let topStackView = UIStackView(arrangedSubviews: [questionLabel, counterLabel])
        topStackView.axis = .horizontal
        topStackView.distribution = .equalSpacing
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        return topStackView
    }

    private func configureBottomStackView() -> UIStackView {
        let bottomButtonsStackView = UIStackView(arrangedSubviews: [noButton, yesButton])
        bottomButtonsStackView.axis = .horizontal
        bottomButtonsStackView.distribution = .fillEqually
        bottomButtonsStackView.spacing = 20
        bottomButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        return bottomButtonsStackView
    }


    func setupLayout() {
        let viewForText = UIView()


        let topStackView = configureTopStackView()
        let bottomStackView = configureBottomStackView()

        let overallStackView = UIStackView(arrangedSubviews: [
            topStackView,
            imageView,
            viewForText,
            bottomStackView
        ])

        overallStackView.translatesAutoresizingMaskIntoConstraints = false
        overallStackView.axis = .vertical
        overallStackView.distribution = .fill
        overallStackView.spacing = 20
        overallStackView.alignment = .fill

        viewForText.addSubview(textLabel)
        view.addSubview(overallStackView)
        view.addSubview(activityIndicator)

        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2/3),

            topStackView.topAnchor.constraint(equalTo: overallStackView.topAnchor),

            bottomStackView.heightAnchor.constraint(equalToConstant: 60),

            textLabel.leadingAnchor.constraint(lessThanOrEqualTo: viewForText.leadingAnchor, constant: 44),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: viewForText.trailingAnchor, constant: -44),
            textLabel.centerYAnchor.constraint(equalTo: viewForText.centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: viewForText.centerXAnchor),

            overallStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            overallStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            overallStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            overallStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        questionLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        task?.cancel()

        currentQuestion = question
        let viewModel = convert(model: question)
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






