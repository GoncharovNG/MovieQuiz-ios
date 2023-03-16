import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: Lifecycle
    
    private var correctAnswers: Int = 0
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var StatisticService = StatisticServiceImplementation()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Actions
    private var isCorrect1: Bool = true
    //Нажатие на кнопку "да"
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    //Нажатие на кнопку "нет"
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    // функция выводящая каритинку и вопрос на экран
    private func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    //Функция показывающая результат ответ (верно - зеленый, не верно - красный)
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // выбор цветов зависимости от правильности ответа
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            
        }
    }
    private func show(quiz result: QuizResultsViewModel) {
        // здесь мы показываем результат прохождения квиза
        // здесь мы создаем объект всплывающего окна
        let alertViewModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        
        let alertPresenter = AlertPresenter()
        alertPresenter.present(view: self, alert: alertViewModel)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        //hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
        }
        
        let alert = AlertPresenter()
        alert.present(view: self, alert: model)
    }
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            imageView.layer.borderColor = UIColor.clear.cgColor
            StatisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            StatisticService.gamesCount += 1
            let text = correctAnswers == presenter.questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" : """
                    "Ваш результат: \(correctAnswers)/10
                    Количество сыгранных квизов: \(StatisticService.gamesCount)
                    Рекорд: \(StatisticService.bestGame.correct)/\(StatisticService.bestGame.total) (\(StatisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", StatisticService.totalAccuracy))%
                    """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            imageView.layer.borderColor = UIColor.clear.cgColor
            presenter.switchToNextQuestion()
            // показать следующий вопрос
            questionFactory?.requestNextQuestion()
        }
    }
    internal func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    internal func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
