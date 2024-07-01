import SwiftUI

struct SignupView: View {
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var birthDate: Date = Date()
    @State private var email: String = ""
    @StateObject private var authManager = AuthManager()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Ad Soyad", text: $fullName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                TextField("Kullanıcı Adı", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                SecureField("Şifre", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                DatePicker("Doğum Tarihi", selection: $birthDate, displayedComponents: .date)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                TextField("E-posta", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                }

                Button(action: {
                    authManager.signUp(email: email, password: password, fullName: fullName, username: username, birthDate: birthDate)
                }) {
                    Text("Üye Ol")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10.0)
                }

                NavigationLink(
                    destination: ContentView(),
                    isActive: $authManager.isUserAuthenticated
                ) {
                    EmptyView()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationBarTitle("Üye Ol", displayMode: .inline)
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
