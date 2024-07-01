import SwiftUI

struct LoginView: View {
    @State private var password: String = ""
    @State private var email: String = ""
    @StateObject private var authManager = AuthManager()
    @State private var showSignupView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                TextField("E-posta", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                SecureField("Şifre", text: $password)
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
                    authManager.signIn(email: email, password: password)
                }) {
                    Text("Giriş Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10.0)
                }
                
                Spacer()
                
                NavigationLink(destination: SignupView(), isActive: $showSignupView) {
                    Button(action: {
                        print("Üye olma işlemi")
                        self.showSignupView = true
                    }) {
                        Text("Üye Ol")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(width: 220, height: 50)
                            .cornerRadius(10.0)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Giriş Yap", displayMode: .inline)
        }
        .environmentObject(authManager)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
