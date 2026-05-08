//
//  HealthMetricsService.swift
//  Luma
//

import Foundation

private struct UserDataRecordUploadRequest: Encodable {
    let data_type: String
    let content: [String: Double]
    let source: String
    let recorded_at: String
}

private struct UserDataRecordUploadResponse: Decodable {
    let id: Int
}

final class HealthMetricsService {
    static let shared = HealthMetricsService()
    private init() {}

    func uploadHeartRate(bpm: Double, sampledAt: Date) async {
        await uploadRecord(dataType: "heart_rate", content: ["heart_rate": bpm], sampledAt: sampledAt)
    }

    func uploadHRV(sdnnMs: Double, sampledAt: Date) async {
        await uploadRecord(dataType: "hrv", content: ["hrv_sdnn_ms": sdnnMs], sampledAt: sampledAt)
    }

    func uploadSleep(hours: Double, sampledAt: Date) async {
        await uploadRecord(dataType: "sleep", content: ["sleep_hours": hours], sampledAt: sampledAt)
    }

    private func uploadRecord(dataType: String, content: [String: Double], sampledAt: Date) async {
        let formatter = ISO8601DateFormatter()
        let payload = UserDataRecordUploadRequest(
            data_type: dataType,
            content: content,
            source: "apple_health_watch",
            recorded_at: formatter.string(from: sampledAt)
        )

        do {
            let _: UserDataRecordUploadResponse = try await APIClient.shared.request(
                path: "/api/data/records/",
                method: "POST",
                body: payload,
                requiresAuth: true
            )
            print("☁️ \(dataType) synced.")
        } catch {
            print("⚠️ \(dataType) sync failed:", error.localizedDescription)
        }
    }
}
