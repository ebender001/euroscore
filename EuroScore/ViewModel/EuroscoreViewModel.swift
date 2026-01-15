//
//  EuroscoreViewModel.swift
//  EuroScore
//
//  Created by Edward Bender on 1/13/26.
//

import SwiftUI
import Combine

class EuroscoreViewModel: ObservableObject {
    @Published var euroscore = Euroscore()
    
    func clearData() {
        euroscore.clear()
    }
}
