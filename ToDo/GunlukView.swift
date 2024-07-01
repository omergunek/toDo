import SwiftUI
import Firebase
import FirebaseFirestore

struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    var text: String
    var date: Date
    var userID: String?
   
    var formattedDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

struct GunlukView: View {
    @State private var newEntryText = ""
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var isEditing = false
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ScrollView {
            VStack {
                Text("Günlük Anılar").font(.title).padding()

                VStack {
                    Text("Alttaki alana dokunarak yazmaya başlayın")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    TextEditor(text: $newEntryText)
                        .frame(minHeight: 100)
                        .background(in: .capsule)
                        .padding()
                
                }.padding()

                ForEach(diaryEntries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.text).padding(.bottom)
                        Text(entry.formattedDateTime)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Divider()
                        HStack {
                            Button(action: {
                                deleteEntry(entry)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing)
                            .buttonStyle(BorderlessButtonStyle())

                            Button(action: {
                                editEntry(entry)
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }.padding()
                }
                
                VStack {
                    Spacer()
                    Button(action: addEntry) {
                        Text("Kaydet").padding().background(Color.blue).foregroundColor(.white).cornerRadius(8)
                    }
                }.padding()
            }
        }
        .onAppear {
            fetchEntriesFromFirestore()
        }
    }
    
    func addEntry() {
        if !newEntryText.isEmpty {
            let newEntry = DiaryEntry(id: UUID(), text: newEntryText, date: Date(), userID: authManager.userData?.userId)
            diaryEntries.insert(newEntry, at: 0)
            saveEntryToFirestore(newEntry)
            newEntryText = ""
        }
    }

    func deleteEntry(_ entry: DiaryEntry) {
        withAnimation {
            diaryEntries.removeAll(where: { $0.id == entry.id })
            deleteEntryFromFirestore(entry)
        }
    }

    func editEntry(_ entry: DiaryEntry) {
        newEntryText = entry.text
        deleteEntry(entry)
        isEditing = true
    }
    
    func saveEntryToFirestore(_ entry: DiaryEntry) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        do {
            try db.collection("users").document(userID).collection("diaryEntries").document(entry.id.uuidString).setData(from: entry)
        } catch {
            print(error)
        }
    }
    
    func fetchEntriesFromFirestore() {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        db.collection("users").document(userID).collection("diaryEntries").order(by: "date", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            diaryEntries = documents.compactMap { document in
                try? document.data(as: DiaryEntry.self)
            }
        }
    }
    
    func deleteEntryFromFirestore(_ entry: DiaryEntry) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        db.collection("users").document(userID).collection("diaryEntries").document(entry.id.uuidString).delete { error in
            if let error = error {
                print(error)
            }
        }
    }
}

struct GunlukView_Previews: PreviewProvider {
    static var previews: some View {
        GunlukView().environmentObject(AuthManager())
    }
}
