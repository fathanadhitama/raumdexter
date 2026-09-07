//
//  WatchConnector.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 02/09/26.
//

import WatchConnectivity
import Combine

internal class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    @Published var latestPayload: MatchGPSPayload?

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
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Receved data: \(messageData)")
        decode(messageData)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let data = userInfo["matchGPSPayload"] as? Data else { return }
        decode(data)
    }
    
    private func decode(_ data: Data) {
        guard let payload = try? JSONDecoder().decode(MatchGPSPayload.self, from: data) else { return }
        DispatchQueue.main.async {
            self.latestPayload = payload
        }
    }
    
}
