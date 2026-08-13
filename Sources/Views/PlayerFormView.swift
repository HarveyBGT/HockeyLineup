import SwiftUI

/// Create or edit a player. Pass an existing `player` to edit in place;
/// omit it to create a new one.
struct PlayerFormView: View {
    var existingPlayer: Player?
    var onSave: (Player) -> Void
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String
    @State private var lastName: String
    @State private var squadNumberText: String
    @State private var isGoalkeeper: Bool
    @State private var captaincy: Player.Captaincy
    @State private var avatar: PlayerAvatar
    @State private var preferredRole: PositionRole?
    @State private var showDeleteConfirm = false

    init(existingPlayer: Player? = nil, onSave: @escaping (Player) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingPlayer = existingPlayer
        self.onSave = onSave
        self.onDelete = onDelete
        _firstName = State(initialValue: existingPlayer?.firstName ?? "")
        _lastName = State(initialValue: existingPlayer?.lastName ?? "")
        _squadNumberText = State(initialValue: existingPlayer?.squadNumber.map(String.init) ?? "")
        _isGoalkeeper = State(initialValue: existingPlayer?.isGoalkeeper ?? false)
        _captaincy = State(initialValue: existingPlayer?.captaincy ?? .none)
        _avatar = State(initialValue: existingPlayer?.avatar ?? PlayerAvatar())
        _preferredRole = State(initialValue: existingPlayer?.preferredRole)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PlayerAvatarView(avatar: avatar, size: 92)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Name") {
                    TextField("First name", text: $firstName)
                        .textInputAutocapitalization(.words)
                    TextField("Surname", text: $lastName)
                        .textInputAutocapitalization(.words)
                }

                Section("Skin Tone") {
                    SwatchRow(colors: PlayerAvatar.skinTones, selectedHex: $avatar.skinToneHex)
                }

                Section("Hair") {
                    Picker("Style", selection: $avatar.hairStyle) {
                        ForEach(PlayerAvatar.HairStyle.allCases) { style in
                            Text(style.label).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)

                    if avatar.hairStyle != .bald {
                        SwatchRow(colors: PlayerAvatar.hairColors, selectedHex: $avatar.hairColorHex)
                    }
                }

                Section("Facial Hair") {
                    Picker("Style", selection: $avatar.beardStyle) {
                        ForEach(PlayerAvatar.BeardStyle.allCases) { style in
                            Text(style.label).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    Toggle("Wears Glasses", isOn: $avatar.wearsGlasses)
                }

                Section("Squad") {
                    TextField("Squad number", text: $squadNumberText)
                        .keyboardType(.numberPad)
                    Toggle("Goalkeeper", isOn: $isGoalkeeper)
                    Picker("Captaincy", selection: $captaincy) {
                        Text("None").tag(Player.Captaincy.none)
                        Text("Captain").tag(Player.Captaincy.captain)
                        Text("Vice-Captain").tag(Player.Captaincy.viceCaptain)
                    }
                    Picker("Usually Plays", selection: $preferredRole) {
                        Text("Not set").tag(PositionRole?.none)
                        ForEach(PositionRole.allCases) { role in
                            Text(role.label).tag(PositionRole?.some(role))
                        }
                    }
                }

                if onDelete != nil {
                    Section {
                        Button("Delete Player", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(existingPlayer == nil ? "New Player" : "Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(firstName.trimmingCharacters(in: .whitespaces).isEmpty
                                  && lastName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Delete this player?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func save() {
        var player = existingPlayer ?? Player()
        player.firstName = firstName.trimmingCharacters(in: .whitespaces)
        player.lastName = lastName.trimmingCharacters(in: .whitespaces)
        player.squadNumber = Int(squadNumberText)
        player.isGoalkeeper = isGoalkeeper
        player.captaincy = captaincy
        player.avatar = avatar
        player.preferredRole = preferredRole
        onSave(player)
        dismiss()
    }
}

private struct SwatchRow: View {
    var colors: [String]
    @Binding var selectedHex: String

    var body: some View {
        HStack(spacing: 12) {
            ForEach(colors, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle().stroke(Color(.separator), lineWidth: 1)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                            .padding(-3)
                            .opacity(selectedHex == hex ? 1 : 0)
                    )
                    .onTapGesture { selectedHex = hex }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PlayerFormView(onSave: { _ in })
}
