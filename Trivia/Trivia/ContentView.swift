//
//  ContentView.swift
//  Trivia
//
//  Created by Sailaja Gorti on 12/4/20.
//

import SwiftUI

struct ContentView: View {
//Properties to manage the questions array and answers
    @State private var questionsArray = [Result]()
    @State var currentQuestion: Result?
    @State var answers: [String] = []
//Properties for the settings view.
    @State private var settingsMode = true
    @State private var category: String = ""
    @State private var numberOfQs: String = ""
    let categoryChoices = ["Animals","Books", "Computers", "General Knowledge", "History", "Science & Nature"]
    let number = ["10", "50"]
//Computed property to select the category and insert it into the urlstring.
    var selectedCategory: String {
        let selection = category
        switch selection {
        case "Animals":
            return "27"
        case "Books":
            return "10"
        case "Computers":
            return "18"
        case "General Knowledge":
            return "9"
        case "History":
            return "23"
        case "Science & Nature":
            return "17"
        default:
            return "10"
        }
    }
    var disabledBtn: Bool {
        return (category == "" || numberOfQs == "")
    }
    
//Properties to manage the answers and score
    @State private var questionIndex = 0
    @State private var score = 0
    @State private var ansTapped = false
    @State private var correctAnswer = ""
    @State private var incorrectAnswer = ""
    @State private var disableTxt = false
//Properties to manage alerts
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var endGameAlert = false
//MARK: - To make the background to clear color
    init() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            Group {
//MARK: - Settings View - Allows the user to select a category and number of questions.
                if settingsMode {
                    Form {
                        Section(header: Text("Select a category")) {
                            Picker(selection: $category, label: Text("Select a category")) {
                                ForEach(categoryChoices, id: \.self) { index in
                                    Text(index)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                        Section(header: Text("Choose number of questions for the game...")) {
                            Picker(selection: $numberOfQs, label: Text("Number of Questions")){
                                ForEach(number, id: \.self) { number in
                                    Text(number)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                settingsMode = false
                                getQuestions()
                            }, label: {
                                Text("Start Game")
                                    .font(.title)
                                    .frame(width: 200, height: 50, alignment: .center)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                                    
                        })
                            .disabled(disabledBtn)
                            Spacer()
                        }
                        
                    }
                } else {
//MARK: - Game View - This view displays questions, answers and the score.
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("\(currentQuestion?.formattedQuestion ?? "")")
                        .padding(20)
                        .lineLimit(nil)
                        .font(.title)
                    VStack(alignment: .center) {
                        List {
                            ForEach(answers, id: \.self) { answer in
                                Text(answer)
                                    .frame(width: 300, height: 50, alignment: .center)
                                    .background(!ansTapped ? Color.blue : ((answer == correctAnswer) ? Color.green : (answer == incorrectAnswer) ? Color.red : Color.blue))
                                    .clipShape(Capsule())
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 5, x: 5.0, y: 5.0)
                                    .onTapGesture(perform: {
                                        checkAnswer(selectedAns: answer)
                                    })
                            }
                            .listRowBackground(Color.clear)
                        }
                        Text("\(alertTitle)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("\(alertMessage)")
                        Spacer()
                    }
                }//End Outer VStack
            }//End ZStack
                }
        }//End Group
//MARK: - Navigation Items, Alerts and Disable/Enable Buttons
            .navigationBarTitle("Trivia!")
            .navigationBarItems(leading: Button(action: {
                settingsMode = true
                category = ""
                numberOfQs = ""
                score = 0
            }, label: {
                Text("Quit")
                    .foregroundColor(disabledBtn ? .gray : .black)
                    .opacity(disabledBtn ? 0.0 : 1.0)
            })
            .disabled(settingsMode)
            ,trailing: Text("Score: \(score)"))
            .alert(isPresented: $endGameAlert, content: {
                Alert(title: Text("Game Over"), message: Text("Your score is \(score)"), primaryButton: .default(Text("Play Another Game"), action: {
                    getQuestions()
                    disableTxt = true
                }), secondaryButton: .destructive(Text("Cancel"), action: {
                    settingsMode = true
                    category = ""
                    numberOfQs = ""
                    score = 0
                }))
            })
        }
    }
//MARK: - This function gets the game data using an url, decodes the JSON and loads the array.
    func getQuestions() {
        
        let urlString = "https://opentdb.com/api.php?amount=\(numberOfQs)&category=\(selectedCategory)&type=multiple"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, error == nil {
                
                let decoder = JSONDecoder()
                let response = try? decoder.decode(Response.self, from: data)
                if let response = response {
                    questionsArray = response.results
                    score = 0
                    questionIndex = 0
                    nextQuestion()
                }
            }
        }.resume()
    }
//MARK: - This function gets the next questions and formats the answers to be displayed on the view.
    func nextQuestion() {
        answers = []
        ansTapped = false
        if questionIndex <= questionsArray.count - 1 {
            questionIndex += 1
        } else {
            endGameAlert = true
        }
        currentQuestion = questionsArray[questionIndex-1]
        answers.append(currentQuestion!.formattedCorrectAnswer)
        for ans in currentQuestion!.formattedIncorrectAnswers {
            answers.append(ans)
        }
        answers.shuffle()
    }
//MARK: - This function checks the answers and updates the score accordingly.
    func checkAnswer(selectedAns: String) {
        ansTapped = true
        if selectedAns == currentQuestion!.formattedCorrectAnswer {
            score += 10
            correctAnswer = selectedAns
            self.alertTitle = "Correct"
            self.alertMessage = "The correct answer is \(selectedAns)"
        } else {
            incorrectAnswer = selectedAns
            self.alertTitle = "Wrong"
            self.alertMessage = "The corect answer is \(currentQuestion!.formattedCorrectAnswer)"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alertTitle = ""
            alertMessage = ""
            nextQuestion()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
