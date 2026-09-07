//
//  WatchToiOSConnector.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 02/09/26.
//

import WatchConnectivity

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
    func sendMatchData(center: LocationSample, ownGoal: LocationSample, samples: [LocationSample], goals: Int, assists: Int, distanceMeters: Double) {
        let payload = MatchGPSPayload(center: center, ownGoal: ownGoal, samples: samples, goals: goals, assists: assists, distanceMeters: distanceMeters)
        guard let data = try? JSONEncoder().encode(payload) else { return }

        if session.isReachable {
            print("Session is reachable, send data")
            session.sendMessageData(data, replyHandler: nil) { error in
                print("Gagal kirim data GPS: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable, transfer data")
            session.transferUserInfo(["matchGPSPayload": data])
        }
    }

}
