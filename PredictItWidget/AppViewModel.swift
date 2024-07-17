//
//  AppViewModel.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/17/24.
//

import Foundation
import Combine

class AppViewModel: ObservableObject {
    let openURLSubject: PassthroughSubject<URL, Never> = PassthroughSubject()
    
    var openURLPublisher: AnyPublisher<URL, Never> {
        openURLSubject.eraseToAnyPublisher()
    }
}
