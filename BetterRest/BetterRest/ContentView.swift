//
//  ContentView.swift
//  BetterRest
//
//  Created by Paulla on 7/10/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeupTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var sleeptime:Date = defaultWakeupTime
    
    static var defaultWakeupTime : Date{
        var date = DateComponents()
        date.hour = 7
        date.minute = 0
        return Calendar.current.date(from: date) ?? .now
    }
    
    
    var body: some View {
        NavigationStack{
            VStack {
                Form{
                    VStack(alignment: .leading, spacing: 0){
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time",selection: $wakeUp,displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours",value: $sleepAmount,in:4...12,step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text("Daily coffee intake")
                            .font(.headline)
                        Stepper(coffeeAmount < 2 ?"\(coffeeAmount) cup" : "\(coffeeAmount) cups",value: $coffeeAmount,in:0...20,step: 1)
                        
                        //                    Stepper("^[\(coffeeAmount) cups](inflect:true)",value: $coffeeAmount,in:0...20,step: 1)
                        
                        Picker("Choose one",selection: $coffeeAmount){
                            ForEach(0...20,id:\.self){number in
                                Text(number < 2 ? "\(number) cup" : "\(number) cups")
                            }
                        }
                    }
                    
                    Section("Your best bedtime:"){
                        Text(sleeptime.formatted(date: .omitted, time: .shortened))
                            .font(.largeTitle.bold())
                    }
                }
                
                Button{
                    calculateBedtime()
                }label: {
                    Text("Calculate")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity,minHeight: 50)
                        .cornerRadius(10)
                        .background(.blue)
                        
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate"){calculateBedtime()}
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("OK"){}
            }message: {
                Text(alertMessage)
            }
        }
    }
    
    
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            sleeptime = sleepTime
            
            alertTitle = "Your ideal bedtime is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showAlert = false
    }
}

#Preview {
    ContentView()
}
