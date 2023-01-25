import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    var activityIndicator: UIActivityIndicatorView! { get set }
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrect: Bool)
    func setupActivityIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func showEndGameAlert()
    func togglenteraction()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {


    //MARK: - Outlets
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var alertPresenter: AlertPresenterProtocol!
    private var presenter: MovieQuizPresenter!

    override var preferredStatusBarStyle : UIStatusBarStyle { .lightContent }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
    }
    
    //MARK: - Private functions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        UIView.transition(with: imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = step.image},
                          completion: nil)
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func togglenteraction() {
        self.noButton.isEnabled.toggle() // отключаем кнопки чтобы нельзя было выбирать во время задержки
        self.yesButton.isEnabled.toggle()
        self.yesButton.alpha = yesButton.isEnabled ? 1.0 : 0.8
        self.noButton.alpha = noButton.isEnabled ? 1.0 : 0.8
    }

    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // делаем рамку зеленой или красной
    }

    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .ypBlack
        activityIndicator.startAnimating() // включаем анимацию
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorAlert = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.startAnimating()
            self.presenter.restartGame()
        }

        alertPresenter?.show(model: errorAlert)
    }

    func showEndGameAlert() {
        let message = presenter.makeResultsMessage()
        let alert = AlertModel(title: "Этот раунд окончен!", message: message, buttonText: "Сыграть еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }

        alertPresenter.show(model: alert)
    }
}






