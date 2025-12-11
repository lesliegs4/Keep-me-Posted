//
//  ProfileView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 12/6/25.
//

import SwiftUI
import Contacts
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var contacts: [CNContact] = []
    @State private var contactAccessDenied: Bool = false
    @State private var isLoadingContacts = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: Profile Information
                VStack(spacing: 16) {
                    // Avatar Placeholder
                    Circle()
                        .fill(Color(red: 0.50, green: 0.69, blue: 0.73).opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .foregroundColor(Color(red: 0.18, green: 0.44, blue: 0.63))
                        )
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(!authVM.userFullName.isEmpty ? authVM.userFullName : (authVM.currentUser?.email ?? "Traveler"))
                            .font(.title2.bold())
                        
                        Text(authVM.currentUser?.email ?? "No Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 32)
                
                Divider()
                
                // MARK: Contacts List
                VStack(alignment: .leading) {
                    Text("Contacts")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    if contactAccessDenied {
                        VStack(spacing: 12) {
                            Text("Access to contacts was denied.")
                                .foregroundColor(.secondary)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if contacts.isEmpty {
                        if isLoadingContacts {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Text("No contacts found.")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        List(contacts, id: \.identifier) { contact in
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 36, height: 36)
                                    .overlay(Text(String(contact.givenName.prefix(1))).foregroundColor(.black))
                                
                                VStack(alignment: .leading) {
                                    Text("\(contact.givenName) \(contact.familyName)")
                                        .fontWeight(.medium)
                                    // Shows first phone number if available
                                    if let phone = contact.phoneNumbers.first?.value.stringValue {
                                        Text(phone)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                
                Spacer()
                
                // --- Logout Button ---
                Button(action: {
                    authVM.signOut()
                    dismiss()
                }) {
                    Text("Log Out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.50, green: 0.69, blue: 0.73))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadContacts()
        }
    }
    
    // MARK: - Contacts Logic
    private func loadContacts() {
        isLoadingContacts = true
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                self.isLoadingContacts = false
                if let error = error {
                    print("Contacts error: \(error.localizedDescription)")
                    self.contactAccessDenied = true
                    return
                }
                
                guard granted else {
                    self.contactAccessDenied = true
                    return
                }
                
                // Fetch Logic
                let keys = [
                    CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey
                ] as [CNKeyDescriptor]
                
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    var fetchedContacts: [CNContact] = []
                    try store.enumerateContacts(with: request) { contact, stop in
                        fetchedContacts.append(contact)
                    }
                    self.contacts = fetchedContacts
                } catch {
                    print("Failed to fetch contacts: \(error)")
                }
            }
        }
    }
}
