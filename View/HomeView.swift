//
//  HomeView.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct HomeView: View {

    @State private var searchText = ""
    @State private var items: [ARItem] = []
    @State private var showingCreateSheet = false
    @State private var showingInstructions = false

    @AppStorage("hasSeenInstructions") private var hasSeenInstructions = false

    private let persistenceManager = PersistenceManager()

    private var filteredItems: [ARItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.itemName.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                
                // Search Bar
                TextField("Room Key.....", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 24) {

                        // Quick Stats
                        HStack {
                            StatCard(
                                title: "Saved Items",
                                value: "\(items.count)",
                                icon: "cube.fill",
                                color: .blue
                                )
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)

                        if filteredItems.isEmpty {
                            VStack {
                                Spacer()
                                Image(systemName: "cube.box.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 8)

                                Text(items.isEmpty ? "No items saved" : "No matching items")
                                    .font(.headline)
                                    .foregroundColor(.gray)

                                if items.isEmpty {
                                    Text("Tap + to add items")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(filteredItems) { item in
                                    NavigationLink(destination: ARSearchItemView(id: item)) {
                                        ItemCard(item: item)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("ForgetMeNot")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !hasSeenInstructions {
                            showingInstructions = true
                        } else {
                            showingCreateSheet = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingInstructions) {
            InstructionView(showInstructions: $showingInstructions, didFinish: {
                hasSeenInstructions = true
                showingCreateSheet = true
            })
        }
        .fullScreenCover(isPresented: $showingCreateSheet, onDismiss: {
            items = persistenceManager.loadItems()
        }) {
            ARSaveItemView()
        }
        .onAppear {
            items = persistenceManager.loadItems()
        }
    }


    private func deleteItem(_ item: ARItem) {
        persistenceManager.deleteItem(item)
        items = persistenceManager.loadItems()
    }
}
