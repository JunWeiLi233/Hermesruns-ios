import Foundation
import SwiftUI

struct RacesView: View {
    @ObservedObject var session: SessionStore

    private var races: [HermesRace] {
        guard let dashboard = session.dashboard else { return [] }
        return dashboard.races
            .filter { $0.canceled != true }
            .sorted { (HermesDate.parse($0.eventDate) ?? .distantFuture) < (HermesDate.parse($1.eventDate) ?? .distantFuture) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HermesSectionLabel(text: "Race center")
                Text("Give the next finish line a place in the plan.")
                    .font(HermesTheme.display)
                    .foregroundStyle(HermesTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if races.isEmpty {
                    HermesCard(fill: HermesTheme.ink) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NO TARGET RACE YET")
                                .font(HermesTheme.section)
                                .tracking(1)
                                .foregroundStyle(HermesTheme.coralSoft)
                            Text("Add a race in the Hermes web app and it will appear here with its countdown and training context.")
                                .font(HermesTheme.body)
                                .foregroundStyle(.white.opacity(0.76))
                        }
                    }
                } else {
                    ForEach(Array(races.enumerated()), id: \.offset) { _, race in
                        RaceCard(race: race)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(HermesTheme.paper.ignoresSafeArea())
        .navigationTitle("Races")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await session.refreshDashboard() }
        .task { if session.dashboard == nil { await session.refreshDashboard() } }
    }
}

private struct RaceCard: View {
    let race: HermesRace

    var body: some View {
        HermesCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: "flag.checkered")
                        .foregroundStyle(HermesTheme.coral)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(race.name?.isEmpty == false ? race.name! : "Target race")
                            .font(HermesTheme.title)
                            .foregroundStyle(HermesTheme.ink)
                        Text(race.location?.isEmpty == false ? race.location! : "Location not set")
                            .font(HermesTheme.caption)
                            .foregroundStyle(HermesTheme.mutedInk)
                    }
                    Spacer()
                    Text(countdown)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(HermesTheme.coral)
                }
                HStack(spacing: 0) {
                    HermesMetric(value: HermesFormatters.date(HermesDate.parse(race.eventDate)), label: "race date")
                    HermesMetric(value: HermesFormatters.distance(race.distanceKm), label: "distance")
                    HermesMetric(value: race.eventDate == nil ? "—" : "target", label: "status")
                }
            }
        }
    }

    private var countdown: String {
        guard let date = HermesDate.parse(race.eventDate) else { return "—" }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return "Past" }
        return "D-\(days)"
    }
}

struct RacesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { RacesView(session: SessionStore(previewDashboard: HermesPreviewFixtures.dashboard)) }
    }
}
