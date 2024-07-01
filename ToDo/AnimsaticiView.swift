import SwiftUI
import Firebase
import FirebaseFirestore

struct Animsatici: Identifiable, Codable {
    var id = UUID()
    var baslik: String
    var aciklama: String
    var durum: Bool
    var tarih: Date
    var userID: String?

    enum CodingKeys: String, CodingKey {
        case id, baslik, aciklama, durum, tarih, userID
    }
}

struct AnimsaticiView: View {
    @State private var animsaticilar: [Animsatici] = []
    @State private var ekranDurumu = false
    @State private var seciliAnimsatici: Animsatici?
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(animsaticilar, id: \.id) { animsatici in
                    AnimsaticiSatir(animsatici: animsatici, toggleDurum: {
                        self.toggleDurum(of: animsatici)
                    }, editMetin: {
                        self.seciliAnimsatici = animsatici
                        self.ekranDurumu = true
                    })
                }
                .onDelete(perform: animsaticiSil)
            }
            .navigationBarTitle("Anımsatıcılar")
            .navigationBarItems(trailing:
                Button(action: {
                    self.ekranDurumu = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $ekranDurumu) {
                if let seciliAnimsatici = self.seciliAnimsatici {
                    AnimsaticiEkleView(
                        animsaticilar: self.$animsaticilar,
                        seciliAnimsatici: seciliAnimsatici,
                        saveAnimsatici: self.saveAnimsaticiToFirestore
                    )
                } else {
                    AnimsaticiEkleView(
                        animsaticilar: self.$animsaticilar,
                        saveAnimsatici: self.saveAnimsaticiToFirestore
                    )
                }
            }
        }
        .onAppear {
            fetchAnimsaticilarFromFirestore()
        }
    }
    
    func animsaticiSil(at offsets: IndexSet) {
        for index in offsets {
            let animsatici = animsaticilar[index]
            deleteAnimsaticiFromFirestore(animsatici)
        }
        animsaticilar.remove(atOffsets: offsets)
    }
    
    func toggleDurum(of animsatici: Animsatici) {
        if let index = animsaticilar.firstIndex(where: { $0.id == animsatici.id }) {
            animsaticilar[index].durum.toggle()
            saveAnimsaticiToFirestore(animsaticilar[index])
        }
    }
    
    // MARK: - Firestore Functions
    
    func saveAnimsaticiToFirestore(_ animsatici: Animsatici) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        do {
            try db.collection("users").document(userID).collection("animsaticilar").document(animsatici.id.uuidString).setData(from: animsatici)
        } catch {
            print(error)
        }
    }
    
    func fetchAnimsaticilarFromFirestore() {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        db.collection("users").document(userID).collection("animsaticilar").order(by: "tarih", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            animsaticilar = documents.compactMap { document in
                try? document.data(as: Animsatici.self)
            }
        }
    }
    
    func deleteAnimsaticiFromFirestore(_ animsatici: Animsatici) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        db.collection("users").document(userID).collection("animsaticilar").document(animsatici.id.uuidString).delete { error in
            if let error = error {
                print(error)
            }
        }
    }
}

struct AnimsaticiSatir: View {
    var animsatici: Animsatici
    var toggleDurum: () -> Void
    var editMetin: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(animsatici.baslik)
                    .font(.headline)
                Text(animsatici.aciklama)
                    .font(.subheadline)
                Text(dateFormatter.string(from: animsatici.tarih))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                self.toggleDurum()
            }) {
                Image(systemName: animsatici.durum ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(animsatici.durum ? .green : .clear)
            }
            Button(action: {
                self.editMetin()
            }) {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct AnimsaticiEkleView: View {
    @Environment(\.presentationMode) var sunumModu
    @State private var baslik = ""
    @State private var aciklama = ""
    @State private var tarih = Date()
    
    @Binding var animsaticilar: [Animsatici]
    var seciliAnimsatici: Animsatici?
    var saveAnimsatici: (Animsatici) -> Void
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Başlık", text: $baslik)
                TextField("Açıklama", text: $aciklama)
                DatePicker("Tarih ve Saat", selection: $tarih, displayedComponents: [.date, .hourAndMinute])
            }
            .onAppear {
                if let seciliAnimsatici = self.seciliAnimsatici {
                    self.baslik = seciliAnimsatici.baslik
                    self.aciklama = seciliAnimsatici.aciklama
                    self.tarih = seciliAnimsatici.tarih
                }
            }
            .navigationBarTitle(seciliAnimsatici != nil ? "Anımsatıcı Düzenle" : "Yeni Anımsatıcı")
            .navigationBarItems(trailing:
                Button("Kaydet") {
                    if let seciliAnimsatici = self.seciliAnimsatici {
                        if let index = self.animsaticilar.firstIndex(where: { $0.id == seciliAnimsatici.id }) {
                            self.animsaticilar[index].baslik = self.baslik
                            self.animsaticilar[index].aciklama = self.aciklama
                            self.animsaticilar[index].tarih = self.tarih
                            saveAnimsatici(self.animsaticilar[index])
                        }
                    } else {
                        let yeniAnimsatici = Animsatici(id: UUID(), baslik: self.baslik, aciklama: self.aciklama, durum: false, tarih: self.tarih, userID: authManager.userData?.userId)
                        self.animsaticilar.append(yeniAnimsatici)
                        saveAnimsatici(yeniAnimsatici)
                    }
                    self.sunumModu.wrappedValue.dismiss()
                }
            )
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct AnimsaticiView_Previews: PreviewProvider {
    static var previews: some View {
        AnimsaticiView().environmentObject(AuthManager())
    }
}
