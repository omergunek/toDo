import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

struct UserData {
    let userId: String
    let fullName: String
    let email: String
    let registrationDate: Date
}

class AuthManager: ObservableObject {
    @Published var isUserAuthenticated = false
    @Published var errorMessage: String?
    @Published var userData: UserData?
    
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isUserAuthenticated = user != nil
            if let user = user {
                self.fetchUserData(for: user.uid)
            } else {
                self.userData = nil
            }
        }
    }
    
    func signUp(email: String, password: String, fullName: String, username: String, birthDate: Date) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Kayıt yapılamadı: \(error.localizedDescription)"
            } else {
                guard let user = authResult?.user else { return }
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "userId": user.uid,
                    "fullName": fullName,
                    "username": username,
                    "birthDate": birthDate,
                    "email": email
                ]) { error in
                    if let error = error {
                        self.errorMessage = "Kayıt yapılamadı: \(error.localizedDescription)"
                    } else {
                        self.isUserAuthenticated = true
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = "Hatalı Giriş: \(error.localizedDescription)"
            } else {
                self?.isUserAuthenticated = true
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isUserAuthenticated = false
        } catch let signOutError as NSError {
            print(signOutError)
        }
    }
    
    private func fetchUserData(for userID: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let fullName = data?["fullName"] as? String ?? ""
                let email = data?["email"] as? String ?? ""
                let registrationDateTimestamp = data?["registrationDate"] as? Timestamp
                let registrationDate = registrationDateTimestamp?.dateValue() ?? Date()
                self.userData = UserData(userId: userID, fullName: fullName, email: email, registrationDate: registrationDate)
            }
        }
    }
}

@main
struct kategoriSayfasiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isUserAuthenticated {
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
