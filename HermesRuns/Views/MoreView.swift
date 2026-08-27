import SwiftUI

struct MoreView: View {
    @ObservedObject var session: SessionStore

    var body: some View {
        List {
            Section {
                MoreLink(title: "Analysis", subtitle: "Training load and recent performance", icon: "waveform.path.ecg") {
                    AnalysisView(session: session)
                }
                MoreLink(title: "Schedule", subtitle: "Your next 14 coached days", icon: "calendar") {
                    ScheduleView(session: session)
                }
                MoreLink(title: "Races", subtitle: "Targets, countdowns, and course context", icon: "flag.checkered") {
                    RacesView(session: session)
                }
                MoreLink(title: "Weather", subtitle: "Acclimatization and pace context", icon: "cloud.sun.fill") {
                    WeatherView(session: session)
                }
                MoreLink(title: "Rewards", subtitle: "Progress built from your logged runs", icon: "rosette") {
                    RewardsView(session: session)
                }
            } header: {
                HermesSectionLabel(text: "Runner tools")
                    .textCase(nil)
            }

            Section {
                MoreLink(title: "Profile", subtitle: "Account and connected services", icon: "person.crop.circle") {
                    ProfileView(session: session)
                }
                MoreLink(title: "Settings", subtitle: "Connection and session controls", icon: "slider.horizontal.3") {
                    SettingsView(session: session)
                }
            } header: {
                HermesSectionLabel(text: "Account")
                    .textCase(nil)
            }

            Section {
                Text("Admin operations, imports, OAuth linking, maps, and shoe editing remain available in the Hermes web app while their native flows are added.")
                    .font(HermesTheme.caption)
                    .foregroundStyle(HermesTheme.mutedInk)
                    .padding(.vertical, 8)
            }
        }
        .scrollContentBackground(.hidden)
        .background(HermesTheme.paper.ignoresSafeArea())
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MoreLink<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    private let destination: () -> Destination

    init(
        title: String,
        subtitle: String,
        icon: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.destination = destination
    }

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(HermesTheme.coral)
                    .frame(width: 40, height: 40)
                    .background(HermesTheme.coralSoft, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HermesTheme.ink)
                    Text(subtitle)
                        .font(HermesTheme.caption)
                        .foregroundStyle(HermesTheme.mutedInk)
                }
            }
            .padding(.vertical, 5)
        }
        .listRowBackground(HermesTheme.paperRaised)
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MoreView(session: SessionStore(previewDashboard: HermesPreviewFixtures.dashboard)) }
    }
}
