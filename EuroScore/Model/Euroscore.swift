//
//  Euroscore.swift
//  EuroScore
//
//  Created by Edward Bender on 1/13/26.
//

import Foundation

struct Euroscore {
    
    init() {
        nyhaII = false
        nyhaIII = false
        nyhaIV = false
        ccs4 = false
        iddm = false
        age = 0
        female = false
        eca = false
        cpd = false
        nmMobility = false
        redo = false
        onDialysis = false
        cc_less_than_50 = false
        cc_50_to_85 = false
        ae = false
        critical = false
        lv_moderate = false
        lv_poor = false
        lv_very_poor = false
        recentMI = false
        pa_systolic_31_to_55 = false
        pa_systolic_gt_55 = false
        urgent = false
        emergency = false
        salvage = false
        oneNonCabg = false
        twoMajorProcedures = false
        threeMajorProcedures = false
        thoracicAorta = false
    }
    
    mutating func clear() {
        nyhaII = false
        nyhaIII = false
        nyhaIV = false
        ccs4 = false
        iddm = false
        age = 0
        female = false
        eca = false
        cpd = false
        nmMobility = false
        redo = false
        onDialysis = false
        cc_less_than_50 = false
        cc_50_to_85 = false
        ae = false
        critical = false
        lv_moderate = false
        lv_poor = false
        lv_very_poor = false
        recentMI = false
        pa_systolic_31_to_55 = false
        pa_systolic_gt_55 = false
        urgent = false
        emergency = false
        salvage = false
        oneNonCabg = false
        twoMajorProcedures = false
        threeMajorProcedures = false
        thoracicAorta = false
    }
    
    //MARK: - VARIABLES
    var nyhaII: Bool {
        willSet {
            if newValue {
                nyhaIII = false
                nyhaIV = false
            }
        }
    }
    var nyhaIII: Bool {
        willSet {
            if newValue {
                nyhaII = false
                nyhaIV = false
            }
        }
    }
    var nyhaIV: Bool {
        willSet {
            if newValue {
                nyhaII = false
                nyhaIII = false
            }
        }
    }
    var ccs4: Bool
    var iddm: Bool
    var age: Int
    var female: Bool
    var eca: Bool
    var cpd: Bool
    var nmMobility: Bool
    var redo: Bool
    var onDialysis: Bool {
        willSet {
            if newValue {
                cc_less_than_50 = false
                cc_50_to_85 = false
            }
        }
    }
    var cc_less_than_50: Bool {
        willSet {
            if newValue {
                onDialysis = false
                cc_50_to_85 = false
            }
        }
    }
    var cc_50_to_85: Bool {
        willSet {
            if newValue {
                cc_less_than_50 = false
                onDialysis = false
            }
        }
    }
    var ae: Bool
    var critical: Bool
    var lv_moderate: Bool {
        willSet {
            if newValue {
                lv_poor = false
                lv_very_poor = false
            }
        }
    }
    var lv_poor: Bool {
        willSet {
            if newValue {
                lv_moderate = false
                lv_very_poor = false
            }
        }
    }
    var lv_very_poor: Bool {
        willSet {
            if newValue {
                lv_moderate = false
                lv_poor = false
            }
        }
    }
    var recentMI: Bool
    var pa_systolic_31_to_55: Bool
    var pa_systolic_gt_55: Bool
    var urgent: Bool {
        willSet {
            if newValue {
                emergency = false
                salvage = false
            }
        }
    }
    var emergency: Bool {
        willSet {
            if newValue {
                urgent = false
                salvage = false
            }
        }
    }
    var salvage: Bool {
        willSet {
            if newValue {
                urgent = false
                emergency = false
            }
        }
    }
    var oneNonCabg: Bool
    var twoMajorProcedures: Bool
    var threeMajorProcedures: Bool
    var thoracicAorta: Bool
    var constant: Double = -5.324537
    var ageCalculation: Double {
        if age <= 60 {
            return Double(1)
        }
        return Double(age - 59)
    }
    
    //MARK: - Calculations
    func canCalculate() -> Bool {
        age >= 18 && age <= 95
    }
    
    private func predictedMortality() -> Double {
        return pow(M_E, exponent())/(1 + pow(M_E, exponent()))
    }
    
    func euroScoreMortalityString() -> String {
        String(format: "%.2f%%", predictedMortality() * 100)
    }
    
    private func exponent() -> Double {
        let value1 = nyhaII.toDouble()*0.1070545 + nyhaIII.toDouble()*0.2958358 + nyhaIV.toDouble()*0.5597929 +
        ccs4.toDouble()*0.2226147 + iddm.toDouble()*0.3542749 + ageCalculation*0.0285181
        
        let value2 = cc_less_than_50.toDouble()*0.8592256 + cc_50_to_85.toDouble()*0.303553 + ae.toDouble()*0.6194522 +
        critical.toDouble()*1.086517 + lv_moderate.toDouble()*0.3150652 + lv_poor.toDouble()*0.8084096 +
        lv_very_poor.toDouble()*0.9346919 + recentMI.toDouble()*0.1528943 + pa_systolic_31_to_55.toDouble()*0.1788899
        
        let value3 = pa_systolic_gt_55.toDouble()*0.3491475 + urgent.toDouble()*0.3174673 + emergency.toDouble()*0.7039121 +
        salvage.toDouble()*1.362947 + oneNonCabg.toDouble()*0.0062188 + twoMajorProcedures.toDouble()*0.5521478 +
        threeMajorProcedures.toDouble()*0.9724533 + thoracicAorta.toDouble()*0.6527205 + constant
        
        let value4 = female.toDouble()*0.2196434 + eca.toDouble()*0.5360268 + cpd.toDouble()*0.1886564 +
        nmMobility.toDouble()*0.2407181 + redo.toDouble()*1.118599 + onDialysis.toDouble()*0.6421508
        
        return value1 + value2 + value3 + value4
    }
    
    //MARK: - EMAIL
    func prepareEmail(for score: String) -> String {
        var str = "Patient ID: \(Date())\n"
        str += "EuroSCORE II: \(score)%\n"
        str += "Age: \(age) years\n"
        str += "Gender: \(female ? "Female" : "Male")\n"
        var renal = "No dysfunction"
        if onDialysis {
            renal = "On dialysis"
        } else if cc_less_than_50 {
            renal = "Creatinine clearance <= 50"
        } else if cc_50_to_85 {
            renal = "Creatinine clearance 50 - 85"
        }
        str += "Renal dysfunction: \(renal)\n"
        str += "Extracardiac arteriopathy: \(eca.toString())\n"
        str += "Poor mobility: \(nmMobility.toString())\n"
        str += "Previous cardiac surgery: \(redo.toString())\n"
        str += "Chronic lung disease: \(cpd.toString())\n"
        str += "Active endocarditis: \(ae.toString())\n"
        str += "Critical pre-op state: \(critical.toString())\n"
        str += "Diabetes on insulin: \(iddm.toString())\n"
        var nyha = "Not specified"
        if nyhaII {
            nyha = "NYHA II"
        } else if nyhaIII {
            nyha = "NYHA III"
        } else if nyhaIV {
            nyha = "NYHA IIV"
        }
        str += "NYHA Class: \(nyha)\n"
        str += "CCS class IV angina: \(ccs4.toString())\n"
        var lvFunction = "Not specified"
        if lv_moderate {
            lvFunction = "Moderate"
        } else if lv_poor {
            lvFunction = "Poor"
        } else if lv_very_poor {
            lvFunction = "Very poor"
        }
        str += "LV function: \(lvFunction)\n"
        str += "Recent MI: \(recentMI.toString())\n"
        var pa = "Not specified"
        if pa_systolic_31_to_55 {
            pa = "31-55 mmHg"
        } else if pa_systolic_gt_55 {
            pa = ">= 55 mmHg"
        }
        str += "PA pressure: \(pa)\n"
        var urgency = "Not specified"
        if urgent {
            urgency = "Urgent"
        } else if emergency {
            urgency = "Emergency"
        } else if salvage {
            urgency = "Salvage"
        }
        str += "Urgency: \(urgency)\n"
        str += "Thoracic aortic surgery: \(thoracicAorta.toString())\n"
        var wt = "Isolated CABG"
        if oneNonCabg {
            wt = "One procedure - non CABG"
        } else if twoMajorProcedures {
            wt = "Two major procedures"
        } else if threeMajorProcedures {
            wt = "Three or more major procedures"
        }
        str += "Weight of procedure: \(wt)\n"
        
        return str
    }
}
