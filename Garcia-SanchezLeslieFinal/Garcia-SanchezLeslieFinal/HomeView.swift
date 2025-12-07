//
//  HomeView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/25/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            // Top bar with location + hamburger menu
            
            HStack {
                Spacer()
                Text("Paris, France")
                    .font(.headline)
                Spacer()
                
                Image(systemName: "line.horizontal.3")
                    .font(.title3)
                    .padding(.trailing, 16)
            }
            .padding(.top, 20)
            .padding(.bottom, 12)
            
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 24) {
                    Spacer()
                    // Create Postcard Button
                    Button(action: {}) {
                        VStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                            
                            Text("Create a Postcard")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color(red: 0.28, green: 0.63, blue: 0.69))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }
                    
                    // Recent activity section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal, 24)
                        
                        ActivityRow(title: "Postcard to Mom - Paris",
                                    time: "Yesterday")
                        
                        ActivityRow(title: "Journal Entry - Eiffel Tower",
                                    time: "2 days ago")
                    }
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            // Bottom Tab Bar
            HStack {
                TabItem(icon: "map", label: "Map")
                TabItem(icon: "book", label: "Journal")
                TabItem(icon: "person", label: "Profile")
                TabItem(icon: "house", label: "Home") // stays visible
            }
            .padding()
            .background(Color.white)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ActivityRow: View {
    var title: String
    var time: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Text(time)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 24)
    }
}

struct TabItem: View {
    var icon: String
    var label: String
    var isActive: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.gray)

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
}
