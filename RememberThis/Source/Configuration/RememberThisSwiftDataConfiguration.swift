//
//  RememberThisSwiftDataConfiguration.swift
//  RememberThis
//
//  Created by gaea on 10/11/24.
//

import SwiftData

class RememberThisSwiftDataConfiguration {
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
    @MainActor
    static var context: ModelContext {
        return RememberThisSwiftDataConfiguration.container.mainContext
    }
    @MainActor
    static func loadData<T: PersistentModel>(_: T.Type) -> [T]? {
        let fetchDescript = FetchDescriptor<T>()
        return try? RememberThisSwiftDataConfiguration.context.fetch(fetchDescript)
    }
}
