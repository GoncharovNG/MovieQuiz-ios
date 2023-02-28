//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Никита Гончаров on 18.02.2023.
//
import UIKit
// для создания "Алерта"
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion:((UIAlertAction) -> Void)?
}

