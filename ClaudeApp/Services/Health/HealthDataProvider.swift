import Foundation

protocol HealthDataProvider: AnyObject, Sendable {
    var sourceType: HealthDataSourceType { get }
    var connectionState: HealthConnectionState { get }
    var isAuthorized: Bool { get }

    func connect() async throws
    func disconnect()
    func fetchDailySummary(for date: Date) async throws -> DailyHealthSummary?
    func fetchDailySummaries(from startDate: Date, to endDate: Date) async throws -> [DailyHealthSummary]
}
