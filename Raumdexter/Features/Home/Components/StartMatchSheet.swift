//
//  StartMatchSheet.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//
import SwiftUI

struct StartMatchPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Match baru dimulai")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                Button("Tutup") { dismiss() }
                    .foregroundColor(AppTheme.accentGreen)
            }
        }
    }
}
