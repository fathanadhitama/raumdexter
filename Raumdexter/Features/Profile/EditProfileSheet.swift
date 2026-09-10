//
//  EditProfileSheet.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 09/09/26.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Form buat ngedit identitas pemain: foto, nama, dan nomor punggung.
struct EditProfileSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [PlayerProfile]

    @State private var name: String = ""
    @State private var jerseyNumber: Int = PlayerProfile.defaultJerseyNumber
    @State private var photoData: Data?
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var didLoadInitialValues = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        photoSection
                        nameSection
                        jerseySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                        .foregroundStyle(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(trimmedName.isEmpty ? AppTheme.tertiaryText : AppTheme.accent)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear(perform: loadInitialValues)
        .task(id: pickerItem) { await loadSelectedPhoto() }
    }

    // MARK: - Photo

    private var photoSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(AppTheme.surfaceElevated)
                        .frame(width: 132, height: 132)

                    if let photoData, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 132, height: 132)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "figure.soccer")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(AppTheme.accent.opacity(0.7))
                    }

                    if isLoadingPhoto {
                        Circle()
                            .fill(Color.black.opacity(0.45))
                            .frame(width: 132, height: 132)
                        ProgressView().tint(.white)
                    }

                    Circle()
                        .stroke(AppTheme.accent.opacity(0.35), lineWidth: 1)
                        .frame(width: 132, height: 132)
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(AppTheme.accent))
                        .overlay(Circle().stroke(AppTheme.background, lineWidth: 3))
                }
            }
            .buttonStyle(.plain)

            if photoData != nil {
                Button("Delete Photo") {
                    photoData = nil
                    pickerItem = nil
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.danger)
            } else {
                Text("Tap to choose photo")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.tertiaryText)
            }
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Name")

            TextField("Player name", text: $name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .cardSurface(cornerRadius: 16)
                .onChange(of: name) { _, newValue in
                    if newValue.count > PlayerProfile.maxNameLength {
                        name = String(newValue.prefix(PlayerProfile.maxNameLength))
                    }
                }
        }
    }

    // MARK: - Jersey

    private var jerseySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Jersey Number")

            HStack {
                Text("#\(jerseyNumber)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
                    .frame(minWidth: 66, alignment: .leading)

                Spacer()

                Stepper(
                    "Jersey Number",
                    value: $jerseyNumber,
                    in: PlayerProfile.jerseyNumberRange
                )
                .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .cardSurface(cornerRadius: 16)
        }
    }

    // MARK: - Data

    private func loadInitialValues() {
        guard !didLoadInitialValues else { return }
        didLoadInitialValues = true

        let profile = profiles.first
        name = profile?.name ?? PlayerProfile.defaultName
        jerseyNumber = profile?.jerseyNumber ?? PlayerProfile.defaultJerseyNumber
        photoData = profile?.photoData
    }

    private func loadSelectedPhoto() async {
        guard let pickerItem else { return }

        isLoadingPhoto = true
        defer { isLoadingPhoto = false }

        if let data = try? await pickerItem.loadTransferable(type: Data.self) {
            photoData = data
        }
    }

    private func save() {
        let finalName = trimmedName.isEmpty ? PlayerProfile.defaultName : trimmedName

        if let profile = profiles.first {
            profile.name = finalName
            profile.jerseyNumber = jerseyNumber
            profile.photoData = photoData
        } else {
            modelContext.insert(
                PlayerProfile(name: finalName, jerseyNumber: jerseyNumber, photoData: photoData)
            )
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    EditProfileSheet()
        .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self, PlayerProfile.self], inMemory: true)
}
