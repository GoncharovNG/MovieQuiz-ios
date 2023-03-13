//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Никита Гончаров on 18.02.2023.
//
import Foundation
//Создаём протокол QuestionFactoryDelegate, который будем использовать в фабрике как делегата.
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
