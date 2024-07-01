import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Anasayfa")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profil")
            }
        }
    }
}

struct HomeView: View {
    @State private var searchText = ""
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack {
                //SearchBar(text: $searchText, isEditing: $isEditing)
                    //.padding()
                    //.frame(maxWidth: .infinity)
                //Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: GunlukView()) {
                        CategoryView(imageName: "pencil", categoryName: "Günlük", backgroundColor: Color.yellow)
                    }
                    .foregroundColor(.black)
                    Spacer()
                    NavigationLink(destination: AnimsaticiView()) {
                        CategoryView(imageName: "calendar", categoryName: "Anımsatıcı", backgroundColor: Color.blue)
                    }
                    .foregroundColor(.black)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: AlisverisView()) {
                        CategoryView(imageName: "cart", categoryName: "Alışveriş", backgroundColor: Color(hex: "6666FF"))
                    }
                    .foregroundColor(.black)
                    Spacer()
                    NavigationLink(destination: OnemliView()) {
                        CategoryView(imageName: "star", categoryName: "Önemli", backgroundColor: Color.red)
                    }
                    .foregroundColor(.black)
                    Spacer()
                }
                Spacer()
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

struct CategoryView: View {
    var imageName: String
    var categoryName: String
    var backgroundColor: Color
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
            Text(categoryName)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 8)
                .foregroundColor(.gray)
            
            TextField("Ara...", text: $text, onEditingChanged: { editing in
                self.isEditing = editing
            })
            .padding(7)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 4)
            .onTapGesture {
            }
            
            Button(action: {
                
            }) {
                Image(systemName: "mic.fill")
                    .padding(.trailing, 8)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
