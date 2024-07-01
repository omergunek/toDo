//
//  SearchBar.swift
//  kategoriSayfası
//
//  Created by Şule Şengül on 30.04.2024.
//

import SwiftUI

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
                // TextField tıklandığında işlem yapılabilir.
            }
            
            Button(action: {
                // Mikrofon simgesine tıklama işlemi
            }) {
                Image(systemName: "mic.fill")
                    .padding(.trailing, 8)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

