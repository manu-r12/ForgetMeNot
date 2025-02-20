//
//  PersistenceManager.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftData
import Foundation

@MainActor
class PersistenceManager {

    let modelContainer: ModelContainer

    let modelContext: ModelContext

    init() {

        do {

            let schema = Schema([ARItem.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: config
            )

            self.modelContext = modelContainer.mainContext

        } catch {

            fatalError("Failed to initialize SwiftData container: \(error)")

        }
    }


    private func deleteAssociatedFiles(for item: ARItem) {

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let arExperienceFile = item.arWorldMapId
        let arExperiencePath = documentsDirectory.appendingPathComponent(arExperienceFile)
        try? fileManager.removeItem(at: arExperiencePath)

        }

        // MARK: Delete an itme
        func deleteItem(_ item: ARItem) {

            deleteAssociatedFiles(for: item)

            modelContext.delete(item)

            do {
                try modelContext.save()
            } catch {
                print("Error deleting item: \(error)")
            }
        }


        // MARK: Save an item
        func saveItem(item: ARItem) {

            modelContext.insert(item)

            do {
                try modelContext.save()
            } catch {
                print("Error Saving Item: \(item)")
            }
        }


        // MARK: Load Items
        func loadItems() -> [ARItem] {

            do {
                let descriptor = FetchDescriptor<ARItem>()
                return try modelContext.fetch(descriptor)
            } catch {
                print("Error Loading Items : \(error)")
                return []
            }

        }

    }
