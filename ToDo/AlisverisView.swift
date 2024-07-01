import SwiftUI
import Firebase
import FirebaseFirestore

struct AlisverisItem: Identifiable, Codable {
    var id = UUID()
    var urunAdi: String
    var fiyat: Double
    var isChecked: Bool
    var userID: String?
    
    enum CodingKeys: String, CodingKey {
        case id, urunAdi, fiyat, isChecked, userID
    }
}

struct AlisverisView: View {
    @State private var alisverisListesi = [AlisverisItem]()
    @State private var yeniUrunAdi = ""
    @State private var yeniFiyat = ""
    @State private var duzenlenenIndex: Int? = nil
    @State private var isEditing = false
    @EnvironmentObject var authManager: AuthManager
    
    // Computed property to calculate the total price
    var toplamFiyat: Double {
        return alisverisListesi.reduce(0) { $0 + $1.fiyat }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(alisverisListesi.indices, id: \.self) { index in
                        let item = alisverisListesi[index]
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.urunAdi)
                                    .font(.headline)
                                Text("Fiyat: \(item.fiyat, specifier: "%.2f") TL")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isChecked ? .green : .gray)
                        }
                        .background(duzenlenenIndex == index ? Color.yellow.opacity(0.3) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isEditing {
                                duzenle(index: index)
                            } else {
                                toggleCheck(for: item)
                            }
                        }
                    }
                    .onDelete(perform: sil)
                }
                .navigationBarTitle("Alışveriş Listesi")
                .navigationBarItems(trailing:
                    Button(action: {
                        isEditing.toggle()
                        if !isEditing {
                            duzenlenenIndex = nil
                            yeniUrunAdi = ""
                            yeniFiyat = ""
                        }
                    }) {
                        Image(systemName: isEditing ? "xmark.circle.fill" : "pencil")
                    }
                )
                
                Divider()
                
                HStack {
                    TextField("Ürün adı", text: $yeniUrunAdi)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Fiyat", text: $yeniFiyat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Button(action: {
                        if isEditing {
                            ekle()
                        } else {
                            let trimmedUrunAdi = yeniUrunAdi.trimmingCharacters(in: .whitespaces)
                            let trimmedFiyat = yeniFiyat.trimmingCharacters(in: .whitespaces)
                            
                            if !trimmedUrunAdi.isEmpty, let fiyat = Double(trimmedFiyat) {
                                let newItem = AlisverisItem(urunAdi: trimmedUrunAdi, fiyat: fiyat, isChecked: false, userID: authManager.userData?.userId)
                                alisverisListesi.append(newItem)
                                saveItemToFirestore(newItem)
                                yeniUrunAdi = ""
                                yeniFiyat = ""
                            }
                        }
                    }) {
                        Text(isEditing ? "Tamam" : "Ekle")
                    }
                    .padding(.horizontal)
                }
                .padding()
                
                // Display the total price
                Text("Toplam Fiyat: \(toplamFiyat, specifier: "%.2f") TL")
                    .font(.headline)
                    .padding()
            }
            .onAppear {
                fetchItemsFromFirestore()
            }
        }
    }
    
    func ekle() {
        guard let fiyat = Double(yeniFiyat), !yeniUrunAdi.isEmpty, let index = duzenlenenIndex else { return }
        
        alisverisListesi[index].urunAdi = yeniUrunAdi
        alisverisListesi[index].fiyat = fiyat
        updateItemInFirestore(alisverisListesi[index])
        duzenlenenIndex = nil
        yeniUrunAdi = ""
        yeniFiyat = ""
    }
    
    func sil(at offsets: IndexSet) {
        offsets.forEach { index in
            deleteItemFromFirestore(alisverisListesi[index])
        }
        alisverisListesi.remove(atOffsets: offsets)
    }
    
    func duzenle(index: Int) {
        yeniUrunAdi = alisverisListesi[index].urunAdi
        yeniFiyat = String(alisverisListesi[index].fiyat)
        duzenlenenIndex = index
    }
    
    func toggleCheck(for item: AlisverisItem) {
        if let index = alisverisListesi.firstIndex(where: { $0.id == item.id }) {
            alisverisListesi[index].isChecked.toggle()
            updateItemInFirestore(alisverisListesi[index])
        }
    }
    
    func saveItemToFirestore(_ item: AlisverisItem) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        do {
            try db.collection("users").document(userID).collection("alisverisListesi").document(item.id.uuidString).setData(from: item)
        } catch {
            print(error)
        }
    }
    
    func fetchItemsFromFirestore() {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        db.collection("users").document(userID).collection("alisverisListesi").getDocuments { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            alisverisListesi = documents.compactMap { document in
                try? document.data(as: AlisverisItem.self)
            }
        }
    }
    
    func updateItemInFirestore(_ item: AlisverisItem) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        do {
            try db.collection("users").document(userID).collection("alisverisListesi").document(item.id.uuidString).setData(from: item)
        } catch {
            print(error)
        }
    }
    
    func deleteItemFromFirestore(_ item: AlisverisItem) {
        let db = Firestore.firestore()
        guard let userID = authManager.userData?.userId else { return }
        db.collection("users").document(userID).collection("alisverisListesi").document(item.id.uuidString).delete { error in
            if let error = error {
                print(error)
            }
        }
    }
}

struct AlisverisView_Previews: PreviewProvider {
    static var previews: some View {
        AlisverisView().environmentObject(AuthManager())
    }
}
