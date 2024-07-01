//
//  DailyView.swift
//  kategoriSayfası
//
//  Created by Şule Şengül on 30.04.2024.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isEditing = false
    
    // İhtiyacınıza göre alışveriş kategorisinin arka plan rengini burada tanımlayabilirsiniz.
    var shoppingBackgroundColor: Color {
        return Color(hex: "6666FF")
    }
    
    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


