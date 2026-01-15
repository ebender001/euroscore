//
//  CreatinineClearanceCalculator.swift
//  EuroScore
//
//  Created by Edward Bender on 1/14/26.
//

import SwiftUI

struct CreatinineClearanceCalculator: View {
    @EnvironmentObject var euroscoreVM: EuroscoreViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var creatinine = ""
    @State private var unitsValue = "µmol/L"
    @State private var ageString = ""
    @State private var weightString = ""
    @State private var genderString = "Male"
    @State private var showAlert = false
    @State private var clearance = "NA"
    
    let units = ["µmol/L", "mg/dL"]
    let gender = ["Male", "Female"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Plasma Creatinine") {
                    HStack {
                        TextField("Enter creatinine", text: $creatinine)
                        Picker("Units", selection: $unitsValue) {
                            ForEach(units, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section("Patient Data") {
                    HStack {
                        Text("Patient age:")
                        TextField("18-95", text: $ageString)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Text("Weight:")
                        TextField("kg", text: $weightString)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Gender")
                        Picker("Gender", selection: $genderString) {
                            ForEach(gender, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Calculate") {
                            if !canCalculate() {
                                showAlert.toggle()
                            } else {
                                clearance = calculate()
                            }
                        }
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Creatinine clearance = \(clearance)")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Creatinine Clearance Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
    
    func calculate() -> String {
        guard let creatinineValue = Double(creatinine),
              let weightValue = Double(weightString),
              let ageValue = Double(ageString) else {
            return "NA"
        }
        
        var adjustedCreatinineNumber = creatinineValue
        var mg = false
        if unitsValue == "mg/dL" {
            mg = true
        }
        if !mg {
            adjustedCreatinineNumber /= 88.4
        }
        var female = false
        if genderString == "Female" {
            female = true
        }
        
        var clearance = (140.0 - ageValue) * weightValue
        if female {
            clearance *= 0.85
        }
        
        clearance /= (72.0 * adjustedCreatinineNumber)
        return String(format: "%.1f mL/min", clearance)
    }
    
    func canCalculate() -> Bool {
        guard !creatinine.isEmpty,
              !weightString.isEmpty,
              !ageString.isEmpty else {
            return false
        }
        
        guard let _ = Double(creatinine),
              let _ = Double(weightString),
              let _ = Double(ageString) else {
            return false
        }
        
        return true
    }
}

#Preview {
    NavigationStack {
        CreatinineClearanceCalculator()
            .environmentObject(EuroscoreViewModel())
    }
}
