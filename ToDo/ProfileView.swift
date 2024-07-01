import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoggedOut: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Text("PROFİL")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 80)

            if let user = authManager.userData {
                Text("Ad Soyad: \(user.fullName)")
                    .padding(.bottom, 10)
                Text("E-posta: \(user.email)")
                    .padding(.bottom, 10)
                Text("Üyelik Tarihi: \(formattedDate(from: user.registrationDate))")
                    .padding(.bottom, 20)
            }

            Spacer()

            Button(action: {
                self.isLoggedOut = true
            }) {
                Text("Çıkış Yap")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 50)
                    .background(Color.blue)
                    .cornerRadius(20.0)
            }
            .padding(.bottom, 150)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .alert(isPresented: $isLoggedOut) {
            Alert(
                title: Text("Çıkış Yap"),
                message: Text("Emin misiniz?"),
                primaryButton: .default(Text("Evet")) {
                    authManager.signOut()
                },
                secondaryButton: .cancel(Text("Hayır"))
            )
        }
    }
    private func formattedDate(from date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
