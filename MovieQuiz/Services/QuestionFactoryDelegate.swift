//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Никита Гончаров on 18.02.2023.
//
import Foundation
//Создаём протокол QuestionFactoryDelegate, который будем использовать в фабрике как делегата.
protocol QuestionFactoryDelegate: AnyObject {
    //Объявляем метод, который должен быть у делегата фабрики.
    func didReceiveNextQuestion(question: QuizQuestion?)
}
