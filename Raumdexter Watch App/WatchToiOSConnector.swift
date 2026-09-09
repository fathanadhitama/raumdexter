//
//  WatchToiOSConnector.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 02/09/26.
//

import WatchConnectivity

/// Balasan dari iPhone setelah nyoba nyimpen match — struct-nya sengaja dibuat lokal
/// (bukan dibagi dari target iOS), cukup sama-sama JSON compatible aja.
private struct MatchSaveAck: Codable {
    let success: Bool
    let errorMessage: String?
}

enum MatchSendResult {
    /// iPhone reachable dan balas konfirmasi tersimpan.
    case success
    /// iPhone gak reachable — data dikirim lewat antrean background,
    /// TIDAK ADA cara buat mastiin ini beneran nyampe/tersimpan.
    case queued
    /// iPhone reachable tapi balas gagal (atau proses kirim itu sendiri error).
    case failure(String)
}

internal class WatchToiOSConnector: NSObject, WCSessionDelegate {

    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        // activationDidCompleteWith
    }

    // swiftlint:disable:next function_parameter_count
    func sendMatchData(
        center: LocationSample,
        ownGoal: LocationSample,
        samples: [LocationSample],
        goals: Int,
        assists: Int,
        distanceMeters: Double
    ) async -> MatchSendResult {
        let payload = MatchGPSPayload(center: center, ownGoal: ownGoal, samples: samples, goals: goals, assists: assists, distanceMeters: distanceMeters)

        guard let data = try? JSONEncoder().encode(payload) else {
            return .failure("Gagal menyiapkan data match untuk dikirim.")
        }

        guard session.isReachable else {
            session.transferUserInfo(["matchGPSPayload": data])
            return .queued
        }

        return await withCheckedContinuation { continuation in
            session.sendMessageData(data, replyHandler: { replyData in
                guard let ack = try? JSONDecoder().decode(MatchSaveAck.self, from: replyData) else {
                    continuation.resume(returning: .failure("Balasan dari iPhone tidak bisa dibaca."))
                    return
                }
                if ack.success {
                    continuation.resume(returning: .success)
                } else {
                    continuation.resume(returning: .failure(ack.errorMessage ?? "iPhone gagal menyimpan match."))
                }
            }, errorHandler: { error in
                continuation.resume(returning: .failure(error.localizedDescription))
            })
        }
    }
}
