import SwiftUI

class NavigationManager: ObservableObject {
    @Published var showingPrivacy = false
    @Published var showingTerms = false
    @Published var showingSupport = false
    
    func showPrivacyView() {
        showingPrivacy = true
    }
    
    func showTermsView() {
        showingTerms = true
    }
    
    func showSupportView() {
        showingSupport = true
    }
}
