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

    func testMusclePlanDecodesRunnerContextAndSessionLibrary() throws {
        let data = #"{"weekContext":{"volumeKm7d":28.5,"loadStatus":"STABLE","recommendedSessionsPerWeek":2},"days":[{"date":"2026-08-27","dayLabel":"Thursday","run":{"workoutType":"EASY","plannedDistanceKm":6.0},"strength":{"title":"Runner foundation","durationMinutes":25}}],"sessions":[{"title":"Runner foundation","durationMinutes":25,"blocks":[{"title":"Core","exercises":[{"name":"Dead bug","sets":3,"repsOrDuration":"8 / side"}]}]}],"todayCheckIn":{"runType":"EASY","entryState":"ACTUAL","distanceKm":5.5,"durationMinutes":30}}"#.data(using: .utf8)!
        let plan = try JSONDecoder().decode(HermesMusclePlan.self, from: data)

        XCTAssertEqual(plan.weekContext?.volumeKm7d, 28.5)
        XCTAssertEqual(plan.days?.first?.strength?.durationMinutes, 25)
        XCTAssertEqual(plan.sessions?.first?.blocks?.first?.exercises?.first?.name, "Dead bug")
        XCTAssertEqual(plan.todayCheckIn?.entryState, "ACTUAL")
    }

    func testInjuryRiskDecodesRiskAndRecentSoreness() throws {
        let data = #"{"acwr":1.24,"sorenessLevel":"MEDIUM","risk":"MODERATE","coachVoice":"Shift toward recovery today.","combinedRiskScore":33,"recommendation":"caution","acwrTrend":"flat","recentLogs":[{"level":"MEDIUM","date":"2026-08-27"}]}"#.data(using: .utf8)!
        let assessment = try JSONDecoder().decode(HermesInjuryRiskAssessment.self, from: data)

        XCTAssertEqual(assessment.risk, "MODERATE")
        XCTAssertEqual(assessment.combinedRiskScore, 33)
        XCTAssertEqual(assessment.recentLogs?.first?.level, "MEDIUM")
    }
}
