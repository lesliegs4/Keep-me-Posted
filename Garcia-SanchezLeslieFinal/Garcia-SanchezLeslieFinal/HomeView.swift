//
//  HomeView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 11/25/25.
//

import SwiftUI

enum Tab {
    case map
    case journal
    case profile // Technically a sheet, but part of the menu
    case home
}

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showProfile = false
    @State private var showCreatePostcard = false
    @State private var selectedTab: Tab = .home // active tab defaults to home
    
    var body: some View { // note this is it's own view
        ZStack {
            // Main Content Switcher
            switch selectedTab {
            case .home:
                homeContent
            case .map:
                MapView() // This is your new MapView
                    .environmentObject(authVM)
            case .journal:
                Text("Journal View Coming Soon") // Placeholder
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
            case .profile:
                // Profile is handled by sheet, so we keep the underlying view
                homeContent
            }
            
            // MARK: Bottom Tab Bar
            VStack {
                Spacer()
                HStack {
                    // MAP BUTTON
                    Button { selectedTab = .map } label: {
                        TabItem(icon: "map", label: "Map", isActive: selectedTab == .map)
                    }
                    
                    // JOURNAL BUTTON
                    Button { selectedTab = .journal } label: {
                        TabItem(icon: "book", label: "Journal", isActive: selectedTab == .journal)
                    }
                    
                    // PROFILE BUTTON
                    Button(action: {
                        showProfile = true
                        // We don't change selectedTab here to keep context
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "person")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            Text("Profile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // HOME BUTTON
                    Button { selectedTab = .home } label: {
                        TabItem(icon: "house", label: "Home", isActive: selectedTab == .home)
                    }
                }
                .padding()
                .background(Color.white)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authVM)
        }
        .onChange(of: authVM.currentUser) { user in
            if user == nil {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $showCreatePostcard) {
            CreatePostcardView()
                .environmentObject(authVM)
        }
    }
    
    // MARK: Home Display
    var homeContent: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()
                Text(authVM.locationDisplayName)
                    .font(.headline)
                Spacer()
                Image(systemName: "line.horizontal.3")
                    .font(.title3)
                    .padding(.trailing, 16)
            }
            .padding(.top, 20)
            .padding(.bottom, 12)
            // MARK: Create Postcard
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 20)
                    Button(action: {
                        showCreatePostcard = true
                    }) {
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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.50, green: 0.69, blue: 0.73)))
                        .padding(.horizontal, 24)
                    }
                    
                    // MARK: Recent Activity
                    Text("Recent Activity")
                        .font(.title2.bold())
                        .padding(.horizontal, 24)

                    VStack(spacing: 16) {
                        ForEach(authVM.recentActivities) { activity in
                            ActivityRow(title: activity.title, time: activity.timeAgo)
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

    // MARK: Helper Subviews
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
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }

    // MARK: Tab View
    struct TabItem: View {
        var icon: String
        var label: String
        var isActive: Bool = false
        
        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: isActive ? icon + ".fill" : icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? Color(red: 0.50, green: 0.69, blue: 0.73) : .gray)

                Text(label)
                    .font(.caption)
                    .foregroundColor(isActive ? Color(red: 0.50, green: 0.69, blue: 0.73) : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }

#Preview {
    HomeView()
}
