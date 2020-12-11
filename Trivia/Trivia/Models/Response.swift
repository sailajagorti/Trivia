//
//  Response.swift
//  Trivia
//
//  Created by Sailaja Gorti on 12/4/20.
//

import Foundation

struct Response: Codable {
    var response_code: Int
    var results: [Result]
}

struct Result: Codable {
    var category: String
    var type: String
    var difficulty: String
    var question: String
    var correct_answer: String
    var incorrect_answers: [String]
    
    
    var formattedQuestion: String {
        let newString = question.replacingMultipleOccurrences(using: (of: "&quot;", with: "\""), (of: "&#039;", with: "'"), (of: "&amp;", with: "&"), (of: "&eacute;", with: "é"), (of: "&rsquo;", with: "'"), (of: "&aacute;", with: "á"), (of: "&uuml;", with: "ü"),(of: "&ouml;", with: "ö"))
        return newString
    }
    
    var formattedCorrectAnswer: String {
        let newString = correct_answer.replacingMultipleOccurrences(using: (of: "&quot;", with: "\""), (of: "&#039;", with: "'"), (of: "&amp;", with: "&"), (of: "&eacute;", with: "é"), (of: "&rsquo;", with: "'"), (of: "&aacute;", with: "á"), (of: "&uuml;", with: "ü"),(of: "&ouml;", with: "ö"))
        return newString
    }
    
    var formattedIncorrectAnswers: [String] {
        var formattedIncorrect = [String]()
        for incorrect in incorrect_answers {
            let newString = incorrect.replacingMultipleOccurrences(using: (of: "&quot;", with: "\""), (of: "&#039;", with: "'"), (of: "&amp;", with: "&"), (of: "&eacute;", with: "é"), (of: "&rsquo;", with: "'"), (of: "&aacute;", with: "á"), (of: "&uuml;", with: "ü"),(of: "&ouml;", with: "ö"))
            formattedIncorrect.append(newString)
        }
        return formattedIncorrect
    }
}
