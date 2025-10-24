//
//  NavigationHolder.swift
//  SourceSyncIntegration
//
//  Created by Antiufieiev Michael on 22.10.2025.
//
import SwiftUI

class NavigationHolder: ObservableObject {
    @Published
    var navigationPath = NavigationPath()

    func navigateTo<T: Hashable>(route: T) {
        navigationPath.append(route)
    }
    
    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
