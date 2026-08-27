import SwiftUI

struct SettingsView: View {
    @ObservedObject var session: SessionStore
    @State private var draftURL = ""
    @State private var savedMessage = ""

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.dashboard.map { HermesDashboardSnapshot(payload: $0).displayName } ?? "Runner")
                        .font(HermesTheme.title)
                        .foregroundStyle(HermesTheme.ink)
                    Text(session.email ?? "Signed in")
                        .font(HermesTheme.caption)
                        .foregroundStyle(HermesTheme.mutedInk)
                }
                .padding(.vertical, 8)
                .listRowBackground(HermesTheme.paperRaised)
            }

            Section {
                TextField("http://localhost:8080", text: $draftURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                Button("Save server URL") {
                    session.updateAPIBaseURL(draftURL)
                    savedMessage = session.errorMessage == nil ? "Server URL saved." : (session.errorMessage ?? "Unable to save URL.")
                }
                .foregroundStyle(HermesTheme.coral)
                if !savedMessage.isEmpty {
                    Text(savedMessage)
                        .font(HermesTheme.caption)
                        .foregroundStyle(session.errorMessage == nil ? HermesTheme.mintInk : HermesTheme.coral)
                }
            } header: {
                HermesSectionLabel(text: "Connection")
                    .textCase(nil)
            } footer: {
                Text("Use an HTTPS deployment on a physical device. Local HTTP is enabled only for development on trusted networks.")
            }

            Section {
                Button(role: .destructive) {
                    Task { await session.logout() }
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }

            Section {
                LabeledContent("App", value: "Hermes iOS")
                LabeledContent("Data", value: "Existing Hermes API")
                LabeledContent("Minimum iOS", value: "16.0")
            } header: {
                HermesSectionLabel(text: "About")
                    .textCase(nil)
            }
        }
        .scrollContentBackground(.hidden)
        .background(HermesTheme.paper.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { draftURL = session.apiBaseURL }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { SettingsView(session: SessionStore(previewDashboard: HermesPreviewFixtures.dashboard)) }
    }
}
