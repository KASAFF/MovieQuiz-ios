//
//  YPError.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 15.01.2023.
//

import Foundation


enum YPError: String, Error {
    case codeError = "Проиозшла ошибка при обработке запроса. Повторите позднее"
    case errorLoadingImage = "Произошла ошибка при загрузке изображения. Повторите попытку позднее"
    case errorInvalidResponse = "Произошла ошибка при загрузке данных. Попробуйте позднее."
    case unknownError = "Произошла неизвестная ошибка. Попробуйте позднее."
}
