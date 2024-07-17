//
//  PredictItWidgetApp.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import SwiftUI

@main
struct PredictItWidgetApp: App {
    @StateObject var appModel: AppViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    guard url.scheme == widgetURLScheme else {
                        return
                    }
                    print("Opening url: \(url)")
                    appModel.openURLSubject.send(url)
                }
                .environmentObject(appModel)
        }
    }
}
