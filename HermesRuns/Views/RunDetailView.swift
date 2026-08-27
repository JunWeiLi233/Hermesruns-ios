import Foundation
import SwiftUI

struct RunDetailView: View {
    let run: HermesRun

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HermesSectionLabel(text: "Run detail")
                Text(run.name?.isEmpty == false ? run.name! : "Run")
                    .font(HermesTheme.display)
                    .foregroundStyle(HermesTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(HermesFormatters.date(run.displayDate))
                    .font(HermesTheme.body)
                    .foregroundStyle(HermesTheme.mutedInk)

                HermesCard(fill: HermesTheme.ink) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("RUN LEDGER")
                            .font(HermesTheme.section)
                            .tracking(1)
                            .foregroundStyle(HermesTheme.coralSoft)
                        HStack(spacing: 0) {
                            HermesMetric(value: HermesFormatters.distance(run.resolvedDistanceKm), label: "distance", valueColor: .white, labelColor: .white.opacity(0.62))
                            HermesMetric(value: HermesFormatters.duration(run.resolvedDurationSeconds), label: "time", valueColor: .white, labelColor: .white.opacity(0.62))
                            HermesMetric(value: HermesFormatters.pace(distanceKm: run.resolvedDistanceKm, seconds: run.resolvedDurationSeconds), label: "pace", valueColor: .white, labelColor: .white.opacity(0.62))
                        }
                    }
                }

                HermesSectionLabel(text: "Run signals")
                HermesCard {
                    VStack(spacing: 0) {
                        DetailRow(label: "Average heart rate", value: formatted(run.averageHeartRate, suffix: " bpm"))
                        Divider().overlay(HermesTheme.line)
                        DetailRow(label: "Elevation gain", value: formatted(run.totalElevationGain, suffix: " m"))
                        Divider().overlay(HermesTheme.line)
                        DetailRow(label: "Average cadence", value: formatted(run.averageCadence, suffix: " spm"))
                        Divider().overlay(HermesTheme.line)
                        DetailRow(label: "Source", value: run.provider?.capitalized ?? "Manual")
                    }
                }

                if let shoeName = run.shoeName, !shoeName.isEmpty {
                    HermesCard(fill: HermesTheme.coralSoft) {
                        HStack(spacing: 12) {
                            Image(systemName: "shoeprints.fill")
                                .foregroundStyle(HermesTheme.coral)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Shoe used")
                                    .font(HermesTheme.caption)
                                    .foregroundStyle(HermesTheme.ink.opacity(0.62))
                                Text(shoeName)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(HermesTheme.ink)
                            }
                        }
                    }
                }

                Text("Maps, lap telemetry, heart-rate samples, elevation recalibration, and run deletion remain available in the Hermes web detail route.")
                    .font(HermesTheme.caption)
                    .foregroundStyle(HermesTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(HermesTheme.paper.ignoresSafeArea())
        .navigationTitle("Run")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatted(_ value: Double?, suffix: String) -> String {
        guard let value else { return "—" }
        return String(format: "%.0f%@", value, suffix)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(HermesTheme.body)
                .foregroundStyle(HermesTheme.mutedInk)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(HermesTheme.ink)
        }
        .padding(.vertical, 12)
    }
}

struct RunDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { RunDetailView(run: HermesPreviewFixtures.dashboard.activities[0]) }
    }
}
