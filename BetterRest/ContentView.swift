//
//  ContentView.swift
//  BetterRest
//
//  Created by Consultant on 6/19/20.
//  Copyright © 2020 Consultant. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTile = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView{
            Form{
                Section(header:Text("When do you want to wake up")
                    .font(.headline)) {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                }
                
                
                Section(header: Text("Desired amount of sleep")
                    .font(.headline)) {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper(value: $coffeAmount, in: 1...20){
                        if coffeAmount == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeAmount) cups")
                        }
                    }
                }
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calculateBedtime){
                    Text("Calculate")
                }
            )
            
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTile), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedtime(){
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTile = "Your ideal bedtime is.."
        } catch {
            alertTile = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
