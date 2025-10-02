import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Spustit po přihlášení", isOn: $launchAtLogin)
            Text("Další nastavení doplníme později.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(minWidth: 280)
    }
}
