import SwiftUI

struct FooterView: View {
    @ObservedObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("© 2025 PixelPerfect. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(themeManager.tertiaryText)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Privacy") {
                        navigationManager.showPrivacyView()
                    }
                    .foregroundColor(themeManager.tertiaryText)
                    .sheet(isPresented: $navigationManager.showingPrivacy) {
                        PrivacyView()
                    }
                    
                    Button("Terms") {
                        navigationManager.showTermsView()
                    }
                    .foregroundColor(themeManager.tertiaryText)
                    .sheet(isPresented: $navigationManager.showingTerms) {
                        TermsView()
                    }
                    
                    Button("Support") {
                        navigationManager.showSupportView()
                    }
                    .foregroundColor(themeManager.tertiaryText)
                    .sheet(isPresented: $navigationManager.showingSupport) {
                        SupportView()
                    }
                }
                .font(.caption)
            }
        }
        .padding()
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                
                Text("Your privacy is important to us. This app processes images locally on your device and does not send any data to external servers.")
                    .font(.body)
                
                Text("We do not collect, store, or transmit any personal information or images.")
                    .font(.body)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .bold()
                
                Text("By using PixelPerfect, you agree to use this app responsibly and in accordance with applicable laws.")
                    .font(.body)
                
                Text("This app is provided as-is without warranty. Use at your own risk.")
                    .font(.body)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Terms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Support")
                    .font(.largeTitle)
                    .bold()
                
                Text("Need help with PixelPerfect? Here are some ways to get support:")
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("• Check our FAQ section")
                    Text("• Contact support via email")
                    Text("• Visit our website for more information")
                }
                .font(.body)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FooterView(themeManager: ThemeManager())
        .environmentObject(NavigationManager())
}
