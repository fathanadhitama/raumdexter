//
//  WatchConnector.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 02/09/26.
//

import WatchConnectivity
import Combine

/// Balasan yang dikirim balik ke watch setelah payload match diproses,
/// biar watch tau beneran tersimpan atau enggak (bukan cuma "udah dikirim").
private struct MatchSaveAck: Codable {
    let success: Bool
    let errorMessage: String?
}

internal class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    /// Di-set oleh `MatchIngestor` — tempat data beneran disimpan ke SwiftData.
    /// Hasilnya dipakai buat nyusun balasan ke watch.
    var onReceivePayload: ((MatchGPSPayload) -> Result<Void, Error>)?

    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    /// Jalur "reachable" — watch nunggu balasan ini buat tau berhasil/gagal.
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        handleIncoming(messageData, replyHandler: replyHandler)
    }

    /// Jalur fallback saat iPhone gak reachable — dikirim via `transferUserInfo`,
    /// gak ada mekanisme balasan sama sekali di WatchConnectivity buat jalur ini.
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let data = userInfo["matchGPSPayload"] as? Data else { return }
        handleIncoming(data, replyHandler: nil)
    }

    private func handleIncoming(_ data: Data, replyHandler: ((Data) -> Void)?) {
        guard let payload = try? JSONDecoder().decode(MatchGPSPayload.self, from: data) else {
            reply(replyHandler, success: false, errorMessage: "Data match rusak atau format tidak dikenali.")
            return
        }

        DispatchQueue.main.async {
            let result = self.onReceivePayload?(payload) ?? .success(())
            switch result {
            case .success:
                self.reply(replyHandler, success: true, errorMessage: nil)
            case .failure(let error):
                self.reply(replyHandler, success: false, errorMessage: error.localizedDescription)
            }
        }
    }

    private func reply(_ replyHandler: ((Data) -> Void)?, success: Bool, errorMessage: String?) {
        guard let replyHandler else { return }
        let ack = MatchSaveAck(success: success, errorMessage: errorMessage)
        replyHandler((try? JSONEncoder().encode(ack)) ?? Data())
    }
}
