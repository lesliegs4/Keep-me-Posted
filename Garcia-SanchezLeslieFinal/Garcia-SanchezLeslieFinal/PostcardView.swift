//
//  PostcardView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 12/8/25.
//
import SwiftUI

struct PostcardTemplate: Identifiable {
    let id: Int
    let name: String
    let borderColor: Color
    let backgroundColor: Color
}

struct PostcardData {
    var template: PostcardTemplate
    var message: String
    var toName: String
    var fromName: String
}


struct PostcardView: View {
    let data: PostcardData
    
    var body: some View {
        ZStack {
            // Background card
            RoundedRectangle(cornerRadius: 16)
                .fill(data.template.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(data.template.borderColor, lineWidth: 4)
                )
            
            HStack {
                // Left side: message
                VStack(alignment: .leading, spacing: 8) {
                    Text("POSTCARD")
                        .font(.caption)
                        .bold()
                    Text(data.message)
                        .font(.footnote)
                        .lineLimit(nil)
                }
                .padding()
                
                Divider()
                    .frame(maxHeight: .infinity)
                
                // Right side: to/from
                VStack(alignment: .leading, spacing: 12) {
                    Text("to: \(data.toName)")
                    Text("from: \(data.fromName)")
                }
                .font(.footnote)
                .padding()
            }
            .padding()
        }
        .frame(height: 220)
        .padding()
    }
}
