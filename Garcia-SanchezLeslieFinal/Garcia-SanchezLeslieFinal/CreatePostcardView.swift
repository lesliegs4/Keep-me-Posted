//
//  CreatePostcardView.swift
//  Garcia-SanchezLeslieFinal
//
//  Created by Leslie Garcia on 12/8/25.
//

import SwiftUI
import Contacts
import FirebaseAuth

struct CreatePostcardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // --- State Variables ---
    
    // Default Templates
    let templates: [PostcardTemplate] = [
        PostcardTemplate(id: 1, name: "Classic Blue", borderColor: .blue, backgroundColor: Color.blue.opacity(0.1)),
        PostcardTemplate(id: 2, name: "Nature Green", borderColor: .green, backgroundColor: Color.green.opacity(0.1)),
        PostcardTemplate(id: 3, name: "Sunny Yellow", borderColor: .orange, backgroundColor: Color.yellow.opacity(0.1)),
        PostcardTemplate(id: 4, name: "Elegant Pink", borderColor: .pink, backgroundColor: Color.pink.opacity(0.03))
    ]
    
    @State private var selectedTemplate: PostcardTemplate
    @State private var message: String = ""
    @State private var toName: String = "Select a Contact"
    
    // Contacts Sheet State
    @State private var showContactPicker = false
    @State private var fetchedContacts: [CNContact] = []
    @State private var isLoadingContacts = false
    
    init() {
        // Initialize with the first template
        _selectedTemplate = State(initialValue: PostcardTemplate(id: 1, name: "Classic Blue", borderColor: .blue, backgroundColor: Color.blue.opacity(0.1)))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - 1. Live Preview
                // We show the postcard card here so users see changes instantly
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    PostcardView(data: PostcardData(
                        template: selectedTemplate,
                        message: message.isEmpty ? "Your message will appear here..." : message,
                        toName: toName == "Select a Contact" ? "Recipient" : toName,
                        fromName: authVM.userFullName.isEmpty ? (authVM.currentUser?.email ?? "Me") : authVM.userFullName
                    ))
                    // Add a border to the preview container for clarity
                    .padding(.vertical)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // MARK: - 2. Template Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a Style")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(templates) { template in
                                TemplateChip(
                                    template: template,
                                    isSelected: selectedTemplate.id == template.id
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedTemplate = template
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // MARK: - 3. Recipient Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        Text(toName)
                            .foregroundColor(toName == "Select a Contact" ? .gray : .primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showContactPicker = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("Contacts")
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(red: 0.50, green: 0.69, blue: 0.73).opacity(0.15))
                            .foregroundColor(Color(red: 0.18, green: 0.44, blue: 0.63))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                    .padding(.horizontal)
                }
                
                // MARK: - 4. Message Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Write something nice...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(12)
                                .padding(.top, 4)
                        }
                        
                        TextEditor(text: $message)
                            .frame(height: 120)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                    }
                    .padding(.horizontal)
                    
                    Text("\(message.count) chars")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                }
                
                // MARK: - 5. Send Button
                Button(action: {
                    // Send Logic Here (e.g., save to Firestore)
                    authVM.addActivity(title: "Postcard Sent to \(toName)")
                        
                    print("Sending postcard to \(toName)")
                    dismiss()
                }) {
                    Text("Send Postcard")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.50, green: 0.69, blue: 0.73))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .disabled(toName == "Select a Contact" || message.isEmpty)
                .opacity((toName == "Select a Contact" || message.isEmpty) ? 0.6 : 1.0)
            }
            .padding(.top)
        }
        .navigationTitle("Create Postcard")
        .navigationBarTitleDisplayMode(.inline)
        // Contacts Sheet
        .sheet(isPresented: $showContactPicker) {
            ContactPickerSheet(contacts: fetchedContacts, isLoading: isLoadingContacts) { selectedContact in
                self.toName = "\(selectedContact.givenName) \(selectedContact.familyName)"
                self.showContactPicker = false
            }
            .onAppear(perform: fetchContacts)
        }
    }
    
    // Helper: Fetch Contacts
    private func fetchContacts() {
        guard fetchedContacts.isEmpty else { // Don't refetch if we have them
            return
        }
        
        isLoadingContacts = true
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                self.isLoadingContacts = false
                guard granted, error == nil else { return }
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    var newContacts: [CNContact] = []
                    try store.enumerateContacts(with: request) { contact, _ in
                        newContacts.append(contact)
                    }
                    self.fetchedContacts = newContacts.sorted { $0.givenName < $1.givenName }
                } catch {
                    print("Error fetching contacts: \(error)")
                }
            }
        }
    }
}

// MARK: - Helper Views

struct TemplateChip: View {
    let template: PostcardTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack {
            // Visual representation of the template colors
            ZStack {
                Rectangle()
                    .fill(template.backgroundColor)
                Rectangle()
                    .strokeBorder(template.borderColor, lineWidth: 3)
            }
            .frame(width: 60, height: 40)
            .cornerRadius(6)
            
            Text(template.name)
                .font(.caption2)
                .foregroundColor(isSelected ? .blue : .primary)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ContactPickerSheet: View {
    let contacts: [CNContact]
    let isLoading: Bool
    var onSelect: (CNContact) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Contacts...")
                } else if contacts.isEmpty {
                    Text("No contacts found or access denied.")
                        .foregroundColor(.gray)
                } else {
                    List(contacts, id: \.identifier) { contact in
                        Button(action: {
                            onSelect(contact)
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color(red: 0.50, green: 0.69, blue: 0.73))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(contact.givenName.prefix(1))
                                            .foregroundColor(.white)
                                            .font(.caption.bold())
                                    )
                                
                                Text("\(contact.givenName) \(contact.familyName)")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Select Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
