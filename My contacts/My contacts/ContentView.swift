//
//  ContentView.swift
//  My contacts
//
//  Created by vikasitha herath on 2023-07-01.

import SwiftUI

struct ContentView: View {
    @State private var selectedContact: Contact? = nil
    @State private var isAddingContact = false
    @State private var newContact: Contact?
    
    @State private var searchText = ""
    
    @State private var contacts: [Contact] = [
        Contact(name: "John Doe", phoneNumber: "123-456-7890", email: "john.doe@example.com", address: "123 Main St"),
        Contact(name: "Jane Smith", phoneNumber: "987-654-3210", email: "jane.smith@example.com", address: "456 Elm St"),
        Contact(name: "David Johnson", phoneNumber: "456-123-7890", email: "david.johnson@example.com", address: "789 Oak St"),
        Contact(name: "Sarah Davis", phoneNumber: "789-123-4560", email: "sarah.davis@example.com", address: "567 Pine St")
    ]
    
    @State private var favoriteContacts: [Contact] = []
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) && !favoriteContacts.contains($0) }
        }
    }
    
    var body: some View {
        NavigationView {
            TabView {
                // Contacts Tab
                VStack(spacing: 20) {
                    ForEach(filteredContacts) { contact in
                        ContactRow(imageName: "person.fill", contact: contact) {
                            addToFavorites(contact)
                        }
                        .onTapGesture {
                            selectedContact = contact
                        }
                    }
                }
                .padding(.horizontal, 20)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Contacts")
                }
                .tag(0)
                
                // Favorites Tab
                VStack(spacing: 20) {
                    ForEach(favoriteContacts) { contact in
                        ContactRow(imageName: "star.fill", contact: contact) {
                            removeFromFavorites(contact)
                        }
                        .onTapGesture {
                            selectedContact = contact
                        }
                    }
                }
                .padding(.horizontal, 20)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
                .tag(1)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isAddingContact) {
                NewContactView(isPresented: $isAddingContact, onSave: { contact in
                    contacts.append(contact)
                })
            }
            .sheet(item: $selectedContact) { contact in
                ContactDetailsView(contact: contact)
            }
            
        }
    }
    
    private func addToFavorites(_ contact: Contact) {
        favoriteContacts.append(contact)
    }
    
    private func removeFromFavorites(_ contact: Contact) {
        if let index = favoriteContacts.firstIndex(of: contact) {
            favoriteContacts.remove(at: index)
        }
    }
}

struct NewContactView: View {
    @Binding var isPresented: Bool
    var onSave: (Contact) -> Void
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Details")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Email", text: $email)
                    
                    
                
TextField("Address", text: $address)
                }
                
                Section {
                    Button(action: {
                        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email, address: address)
                        onSave(newContact)
                        isPresented = false
                    }) {
                        Text("Save")
                    }
                }
            }
            .navigationBarTitle("New Contact", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
            })
        }
    }
}

struct ContactRow: View {
    var imageName: String
    var contact: Contact
    var action: () -> Void
    
    @State private var isCalling = false
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.blue)
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(contact.phoneNumber)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                isCalling = true
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.blue)
                    .font(.title)
            }
            .actionSheet(isPresented: $isCalling) {
                ActionSheet(
                    title: Text("Call \(contact.name)"),
                    message: Text("Choose SIM"),
                    buttons: [
                        .default(Text("SIM 1"), action: {
                            print("Calling \(contact.name) using SIM 1")
                        }),
                        .default(Text("SIM 2"), action: {
                            print("Calling \(contact.name) using SIM 2")
                        }),
                        .cancel()
                    ]
                )
            }
            
            Button(action: {
                action()
            }) {
                Image(systemName: "star")
                    .foregroundColor(.blue)
                    .font(.title)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct Contact: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let email: String
    let address: String
}

struct ContactDetailsView: View {
    var contact: Contact
    
    var body: some View {
        VStack {
            Text(contact.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(label: "Phone", value: contact.phoneNumber)
                DetailRow(label: "Email", value: contact.email)
                DetailRow(label: "Address", value: contact.address)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct DetailRow: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .foregroundColor(.black)
        }
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
