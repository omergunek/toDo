import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum Importance: Int, Codable {
    case low
    case medium
    case high
}

struct OnemliView: View {
    @State private var reminders: [Reminder] = []
    @State private var reminderText = ""
    @State private var selectedImportance: Importance = .low
    @State private var selectedColor: Color = .green
    @State private var selectedReminderIndex: Int?
    @EnvironmentObject var authManager: AuthManager
    
    var importanceColors: [Color] = [.green, .yellow, .red]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(reminders.indices, id: \.self) { index in
                        Button(action: {
                            self.selectedReminderIndex = index
                            let reminder = self.reminders[index]
                            self.reminderText = reminder.text
                            self.selectedImportance = reminder.importance
                            if let uiColor = UIColor(hex: reminder.color) {
                                self.selectedColor = Color(uiColor)
                            }
                        }) {
                            Text(self.reminders[index].text)
                                .foregroundColor(Color(UIColor(hex: self.reminders[index].color) ?? .black))
                        }
                    }
                    .onDelete(perform: deleteReminder)
                }
                
                TextField("Hatırlatıcı metni girin", text: $reminderText)
                    .padding()
                
                HStack {
                    ForEach(importanceColors, id: \.self) { color in
                        Button(action: {
                            switch color {
                            case .green:
                                self.selectedImportance = .low
                            case .yellow:
                                self.selectedImportance = .medium
                            case .red:
                                self.selectedImportance = .high
                            default:
                                break
                            }
                            self.selectedColor = color
                        }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                
                                if self.selectedColor == color {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    guard !self.reminderText.isEmpty else {
                        return
                    }
                    if let index = self.selectedReminderIndex {
                        self.reminders[index].text = self.reminderText
                        self.reminders[index].importance = self.selectedImportance
                        self.reminders[index].color = self.selectedColor.toHex() ?? "000000"
                        saveReminderToFirestore(self.reminders[index])
                    } else {
                        let newReminder = Reminder(text: self.reminderText, importance: self.selectedImportance, color: self.selectedColor.toHex() ?? "000000", userID: self.authManager.userData?.userId)
                        self.reminders.append(newReminder)
                        saveReminderToFirestore(newReminder)
                    }
                    self.reminderText = ""
                    self.selectedReminderIndex = nil
                }) {
                    Text(self.selectedReminderIndex == nil ? "Hatırlatıcı Ekle" : "Hatırlatıcıyı Düzenle")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitle("Önemli")
            .onAppear {
                fetchRemindersFromFirestore()
            }
        }
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            deleteReminderFromFirestore(reminder)
        }
        reminders.remove(atOffsets: offsets)
    }
    
    func fetchRemindersFromFirestore() {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        
        db.collection("users").document(userID).collection("reminders").getDocuments { querySnapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            self.reminders = documents.compactMap { document in
                try? document.data(as: Reminder.self)
            }
        }
    }
    
    private func saveReminderToFirestore(_ reminder: Reminder) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        
        do {
            try db.collection("users").document(userID).collection("reminders").document(reminder.id.uuidString).setData(from: reminder)
        } catch {
            print(error)
        }
    }
    
    private func deleteReminderFromFirestore(_ reminder: Reminder) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        
        db.collection("users").document(userID).collection("reminders").document(reminder.id.uuidString).delete { error in
            if let error = error {
                print(error)
            }
        }
    }
}

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var text: String
    var importance: Importance
    var color: String
    var userID: String?

    enum CodingKeys: String, CodingKey {
        case id, text, importance, color, userID
    }

    init(text: String, importance: Importance, color: String, userID: String? = nil) {
        self.text = text
        self.importance = importance
        self.color = color
        self.userID = userID
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        let start = hex.index(hex.startIndex, offsetBy: 0)
        let hexColor = String(hex[start...])

        guard hexColor.count == 6,
              let hexNumber = UInt64(hexColor, radix: 16) else {
            return nil
        }

        r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
        b = CGFloat(hexNumber & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
