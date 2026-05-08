//
//  LoginRequest.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct TokenResponse: Decodable {
    let refresh: String
    let access: String
}

// 先按最常见的 /api/me 返回写：id/username/email
// 如果你 curl 出来字段不一样，我们再改成你实际的
struct MeResponse: Decodable {
    let id: Int
    let username: String
    let email: String?
}

struct RiskAlertListResponse: Decodable {
    let alerts: [RiskAlertItem]
}

struct RiskAlertItem: Decodable, Identifiable {
    let id: Int
    let riskLevel: String
    let alertMessage: String
    let riskReasons: [String]
    let recommendedActions: [String]
    let urgencyTTLMinutes: Int?
    let recordedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case riskLevel = "risk_level"
        case alertMessage = "alert_message"
        case riskReasons = "risk_reasons"
        case recommendedActions = "recommended_actions"
        case urgencyTTLMinutes = "urgency_ttl_minutes"
        case recordedAt = "recorded_at"
    }
}

struct NewChatSessionResponse: Decodable {
    let ok: Bool
    let sessionID: String
    let markerID: Int
    let summaryCheckpointCreated: Bool

    enum CodingKeys: String, CodingKey {
        case ok
        case sessionID = "session_id"
        case markerID = "marker_id"
        case summaryCheckpointCreated = "summary_checkpoint_created"
    }
}