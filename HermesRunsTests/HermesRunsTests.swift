import XCTest
@testable import HermesRuns

final class HermesRunsTests: XCTestCase {
    func testDurationFormatterKeepsHoursAndSeconds() {
        XCTAssertEqual(HermesFormatters.duration(3661), "1:01:01")
    }

    func testPaceFormatterUsesKilometresPerHourEquivalentPace() {
        XCTAssertEqual(HermesFormatters.pace(distanceKm: 10, seconds: 3000), "5:00 /km")
    }

    func testPlannedTimeFormatterHandlesMinutesAndHours() {
        XCTAssertEqual(HermesFormatters.plannedTime(minutes: 44), "44 min")
        XCTAssertEqual(HermesFormatters.plannedTime(minutes: 75), "1:15")
    }

    func testPreviewDashboardDecodesTheNativeRunnerSurface() {
        let dashboard = HermesPreviewFixtures.dashboard
        XCTAssertEqual(dashboard.activities.count, 3)
        XCTAssertEqual(dashboard.coachToday?.today?.plannedDistanceKm, 7.5)
        XCTAssertEqual(dashboard.shoes.count, 2)
        XCTAssertNotNil(HermesDate.parse("2026-08-27"))
    }

    func testBaseURLNormalizationAddsDevelopmentScheme() {
        XCTAssertEqual(HermesAPIClient.normalizedURL("localhost:8080")?.absoluteString, "http://localhost:8080")
    }
}
