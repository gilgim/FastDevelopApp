//
//  RememberThisApp.swift
//  RememberThis
//
//  Created by gaea on 10/10/24.
//

import SwiftUI
import SwiftData

@main
struct RememberThisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(RememberThisConfiguration.container)
    }
}

class RememberThisConfiguration {
    static let container: ModelContainer = {
        do {
            let fullSchema = Schema([
                RememberModel.self,
                RememberDateModel.self
            ])
            /**
             아래와 같이 따로 일부 스키마만 경로를 지정해서 사용가능.
             
             let trips = ModelConfiguration(
             schema: Schema([
             Trip.self,
             BucketListItem.self,
             LivingAccommodations.self
             ]),
             url: URL(filePath: "/path/to/trip.store"),
             cloudKitContainerIdentifier: "com.example.trips"
             )
             
             let people = ModelConfiguration(
             schema: Schema([Person.self, Address.self]),
             url: URL(filePath: "/path/to/people.store"),
             cloudKitContainerIdentifier: "com.example.people"
             )
             let container = try ModelContainer(for: fullSchema, people, trips)
             */
            let container = try ModelContainer(for: fullSchema)
            return container
        } catch {
            fatalError()
        }
    }()
    @MainActor var context: ModelContext {
        return RememberThisConfiguration.container.mainContext
    }
    @MainActor
    func loadData<T: PersistentModel>(_: T.Type) -> [T]? {
        let fetchDescript = FetchDescriptor<T>()
        return try? context.fetch(fetchDescript)
    }
}
