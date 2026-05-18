//
//  ActivityVC.swift
//  SwByeDPI
//
//  Created by developer on 05.03.2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit) && !os(tvOS)
///Shows share activity controller through SwiftUI modifiers (fullscreen modal)
struct ActivityVC: UIViewControllerRepresentable {
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    @Binding var presented: Bool
    
    init(presented: Binding<Bool>, activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        _presented = presented
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityVC>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            presented = false
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityVC>) {
        
    }
}
#endif
