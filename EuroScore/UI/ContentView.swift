//
//  ContentView.swift
//  EuroScore
//
//  Created by Edward Bender on 1/13/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var euroscoreVM: EuroscoreViewModel
    @Environment(\.openURL) private var openUrl
    
    private enum ExpandedSection {
        case patient, cardiac, operation
    }

    @State private var expandedSection: ExpandedSection? = .patient
    
    @State private var showCreatinineClearanceCalculator = false
    @State private var showMenu = false
    
    @State private var creatinineClearanceValue = ">85"
    @State private var nyhaClassValue = "I"
    @State private var efValue = ">50%"
    @State private var paPressureValue = "Normal"
    @State private var urgencyValue = "Elective"
    @State private var weightOfInterventionValue = "CABG only"
    @State private var ageString = ""
    @FocusState private var ageFieldFocused: Bool
    
    let creatinineClearance = [">85", "50-85", "<50", "Dialysis"]
    let nyhaClass = ["I", "II", "III", "IV"]
    let ef = [">50%", "31-50%", "21-30%", "<=21%"]
    let paPressure = ["Normal", "31-55", ">55"]
    let urgency = ["Elective", "Urgent", "Emergent", "Salvage"]
    let weightOfIntervention = ["CABG only", "1", "2", "3"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("EuroSCORE Calculation") {
                    if !euroscoreVM.euroscore.canCalculate() {
                        Text("Mortality estimation: N/A")
                            .font(.title3)
                    } else {
                        Text("Mortality estimation: \(euroscoreVM.euroscore.euroScoreMortalityString())")
                            .font(.title3)
                    }
                }
                Section {
                    DisclosureGroup("Patient Factors", isExpanded: Binding(
                        get: { expandedSection == .patient },
                        set: { expandedSection = $0 ? .patient : nil }
                    )) {
                        patientFactors
                    }
                    
                    DisclosureGroup("Cardiac Factors", isExpanded: Binding(
                        get: { expandedSection == .cardiac },
                        set: { expandedSection = $0 ? .cardiac : nil }
                    )) {
                        cardiacFactors
                    }
                    
                    DisclosureGroup("Operation Factors", isExpanded: Binding(
                        get: { expandedSection == .operation },
                        set: { expandedSection = $0 ? .operation : nil }
                    )) {
                        operationFactors
                    }
                }
            }
            .navigationTitle("EuroSCORE II")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMenu.toggle()
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreatinineClearanceCalculator) {
            NavigationStack {
                CreatinineClearanceCalculator()
                
            }
        }
        .alert(Text("Options"), isPresented: $showMenu) {
            Button("New case") {
                euroscoreVM.clearData()
                clearUI()
            }
            Button("Email case") {
                sendEmail(openUrl: openUrl)
            }
            Button("Cancel") {
                
            }
        }
    }
    
    //MARK: - UI
    func sendEmail(openUrl: OpenURLAction) {
        let bodyString = euroscoreVM.euroscore.prepareEmail(for: euroscoreVM.euroscore.euroScoreMortalityString())
        let urlString = "mailto:?subject=Case_\(Date.now)&body=\(bodyString)"
        guard let url = URL(string: urlString) else { return }
        openUrl(url){ accepted in
            if !accepted {
                print("NO GOOD")
            }
        }
    }
    
    func clearUI() {
        creatinineClearanceValue = ">85"
        nyhaClassValue = "I"
        efValue = ">50%"
        paPressureValue = "Normal"
        urgencyValue = "Elective"
        weightOfInterventionValue = "CABG only"
        ageString = ""
        expandedSection = .patient
    }
    
    
    //MARK: - FUNCTIONS FOR MODEL
    func weightFunction() {
        switch weightOfInterventionValue {
        case "CABG only":
            euroscoreVM.euroscore.oneNonCabg = false
            euroscoreVM.euroscore.twoMajorProcedures = false
            euroscoreVM.euroscore.threeMajorProcedures = false
        case "1":
            euroscoreVM.euroscore.oneNonCabg = true
            euroscoreVM.euroscore.twoMajorProcedures = false
            euroscoreVM.euroscore.threeMajorProcedures = false
        case "2":
            euroscoreVM.euroscore.oneNonCabg = false
            euroscoreVM.euroscore.twoMajorProcedures = true
            euroscoreVM.euroscore.threeMajorProcedures = false
        case "3":
            euroscoreVM.euroscore.oneNonCabg = false
            euroscoreVM.euroscore.twoMajorProcedures = false
            euroscoreVM.euroscore.threeMajorProcedures = true
        default:
            break
        }
    }
    
    func urgencyFunction() {
        switch urgencyValue {
        case "Elective":
            euroscoreVM.euroscore.urgent = false
            euroscoreVM.euroscore.emergency = false
            euroscoreVM.euroscore.salvage = false
        case "Urgent":
            euroscoreVM.euroscore.urgent = true
            euroscoreVM.euroscore.emergency = false
            euroscoreVM.euroscore.salvage = false
        case "Emergent":
            euroscoreVM.euroscore.urgent = false
            euroscoreVM.euroscore.emergency = true
            euroscoreVM.euroscore.salvage = false
        case "Salvage":
            euroscoreVM.euroscore.urgent = false
            euroscoreVM.euroscore.emergency = false
            euroscoreVM.euroscore.salvage = true
        default:
            break
        }
    }
    
    func paPressureFunction() {
        switch paPressureValue {
        case "Normal":
            euroscoreVM.euroscore.pa_systolic_31_to_55 = false
            euroscoreVM.euroscore.pa_systolic_gt_55 = false
        case "31-55":
            euroscoreVM.euroscore.pa_systolic_31_to_55 = true
            euroscoreVM.euroscore.pa_systolic_gt_55 = false
        case ">55":
            euroscoreVM.euroscore.pa_systolic_31_to_55 = false
            euroscoreVM.euroscore.pa_systolic_gt_55 = true
        default:
            break
        }
    }
    
    func efFunction() {
        switch efValue {
        case ">50%":
            euroscoreVM.euroscore.lv_moderate = false
            euroscoreVM.euroscore.lv_poor = false
            euroscoreVM.euroscore.lv_very_poor = false
        case "31-50%":
            euroscoreVM.euroscore.lv_moderate = true
            euroscoreVM.euroscore.lv_poor = false
            euroscoreVM.euroscore.lv_very_poor = false
        case "21-30%":
            euroscoreVM.euroscore.lv_moderate = false
            euroscoreVM.euroscore.lv_poor = true
            euroscoreVM.euroscore.lv_very_poor = false
        case "<21%":
            euroscoreVM.euroscore.lv_moderate = false
            euroscoreVM.euroscore.lv_poor = false
            euroscoreVM.euroscore.lv_very_poor = true
        default:
            break
        }
    }
    
    func nyhaFunction() {
        switch nyhaClassValue {
        case "I":
            euroscoreVM.euroscore.nyhaII = false
            euroscoreVM.euroscore.nyhaIII = false
            euroscoreVM.euroscore.nyhaIV = false
        case "II":
            euroscoreVM.euroscore.nyhaII = true
            euroscoreVM.euroscore.nyhaIII = false
            euroscoreVM.euroscore.nyhaIV = false
        case "III":
            euroscoreVM.euroscore.nyhaII = false
            euroscoreVM.euroscore.nyhaIII = true
            euroscoreVM.euroscore.nyhaIV = false
        case "IV":
            euroscoreVM.euroscore.nyhaII = false
            euroscoreVM.euroscore.nyhaIII = false
            euroscoreVM.euroscore.nyhaIV = true
        default:
            break
        }
    }
    
    func renalFunction() {
        switch creatinineClearanceValue {
        case ">85":
            euroscoreVM.euroscore.onDialysis = false
            euroscoreVM.euroscore.cc_50_to_85 = false
            euroscoreVM.euroscore.cc_less_than_50 = false
        case "50-85":
            euroscoreVM.euroscore.onDialysis = false
            euroscoreVM.euroscore.cc_50_to_85 = true
            euroscoreVM.euroscore.cc_less_than_50 = false
        case "<50":
            euroscoreVM.euroscore.onDialysis = false
            euroscoreVM.euroscore.cc_50_to_85 = false
            euroscoreVM.euroscore.cc_less_than_50 = true
        case "Dialysis":
            euroscoreVM.euroscore.onDialysis = true
            euroscoreVM.euroscore.cc_50_to_85 = false
            euroscoreVM.euroscore.cc_less_than_50 = false
        default:
            break
        }
    }
    
    //MARK: - UI
    var operationFactors: some View {
        VStack(alignment: .leading) {
            Text("Urgency:")
            Picker("Urgency", selection: $urgencyValue) {
                ForEach(urgency, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            .onChange(of: urgencyValue) {
                urgencyFunction()
            }
            
            Toggle("Thoracic aortic surgery:", isOn: $euroscoreVM.euroscore.thoracicAorta)
            
            Text("Weight of intervention:")
            Picker("Weight", selection: $weightOfInterventionValue) {
                ForEach(weightOfIntervention, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: weightOfInterventionValue) {
                weightFunction()
            }
            
            Text("Use key below")
                .foregroundColor(.secondary)
                .padding(.bottom)
            Text("1. Single non CABG")
            Text("2. Two procedures")
            Text("3. Three or more procedures")
                
        }
    }
    
    var cardiacFactors: some View {
        VStack(alignment: .leading) {
            Text("NYHA Class:")
            Picker("NYHA", selection: $nyhaClassValue) {
                ForEach(nyhaClass, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            .onChange(of: nyhaClassValue) {
                nyhaFunction()
            }
            
            Toggle("CCS class 4 angina:", isOn: $euroscoreVM.euroscore.ccs4)
                .padding(.bottom)
            
            Text("LV ejection fraction:")
            Picker("LVEF", selection: $efValue) {
                ForEach(ef, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            .onChange(of: efValue) {
                efFunction()
            }
            
            Toggle("Recent MI:", isOn: $euroscoreVM.euroscore.recentMI)
            
            Text("PA systolic pressure (mmHg):")
            Picker("PA Pressure", selection: $paPressureValue) {
                ForEach(paPressure, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: paPressureValue) {
                paPressureFunction()
            }
        }
    }
    
    var patientFactors: some View {
        VStack{
            HStack {
                Text("Patient Age:")
                Spacer()
                TextField("years", text: $ageString)
                    .keyboardType(.numberPad)
                    .focused($ageFieldFocused)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: ageString) {
                        euroscoreVM.euroscore.age = Int(ageString) ?? 0
                    }
                Button {
                    ageFieldFocused = false
                } label: {
                    Image(systemName: "checkmark.circle")
                }
                .opacity(ageFieldFocused ? 1 : 0)
                .allowsHitTesting(!ageFieldFocused)
                .scaleEffect(!ageFieldFocused ? 0.9 : 1.4)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: !ageFieldFocused)
            }
            
            Toggle("Female Gender:", isOn: $euroscoreVM.euroscore.female)
                .padding(.bottom)
                                    
            VStack(spacing: 0) {
                Text("Renal Impairment (creatinine clearance):")
                    .padding(.leading, -10)
                Picker("Renal Impairment", selection: $creatinineClearanceValue) {
                    ForEach(creatinineClearance, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }
                .onChange(of: creatinineClearanceValue, {
                    renalFunction()
                })
                .pickerStyle(.segmented)
                .padding(.bottom)
                Text("Creatinine Clearance Calculator")
                    .font(.caption)
                    .padding(.top)
                    .padding(.bottom)
                    .onTapGesture {
                        showCreatinineClearanceCalculator.toggle()
                    }
            }
            
            Toggle("Extracardiac arteriopathy:", isOn: $euroscoreVM.euroscore.eca)
            Toggle("Poor mobility:", isOn: $euroscoreVM.euroscore.nmMobility)
            Toggle("Previous cardiac surgery:", isOn: $euroscoreVM.euroscore.redo)
            Toggle("Chronic lung disease:", isOn: $euroscoreVM.euroscore.cpd)
            Toggle("Active endocarditis", isOn: $euroscoreVM.euroscore.ae)
            Toggle("Critical preop state:", isOn: $euroscoreVM.euroscore.critical)
            Toggle("Diabetes on insulin:", isOn: $euroscoreVM.euroscore.iddm)

        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .environmentObject(EuroscoreViewModel())
    }
}
