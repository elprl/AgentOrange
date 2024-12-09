//
//  DataService.swift
//  AgentOrange
//
//  Created by Paul Leo on 18/07/2024.
//

import Foundation
import SwiftData

protocol PersistentModelProtocol: PersistentModel {
    associatedtype SendableModel: SendableModelProtocol
    var sendableModel: SendableModel { get }
}

protocol SendableModelProtocol: Sendable {
    associatedtype Model: PersistentModelProtocol
    var persistentModel: Model { get }
}

protocol DataServiceProtocol: ModelActor {
    associatedtype Model: PersistentModelProtocol
    func insert(data: Model) async
    func fetchData(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [Model]
    func fetchDataIds(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [PersistentIdentifier]
    func remove(predicate: Predicate<Model>?) async throws
    func remove(id: PersistentIdentifier) async
    func save() async throws
    func saveAndInsertIfNeeded(data: Model, predicate: Predicate<Model>) async throws
}

protocol DataServiceSendableProtocol: DataServiceProtocol {
    associatedtype SendableModel: SendableModelProtocol
    func fetchDataVMs(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [SendableModel]
    func insert(data: SendableModel) async
}

extension DataServiceProtocol {
    func insert(data: Model) async {
        modelContext.insert(data)
        try? modelContext.save()
    }
    
    func fetchData(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [Model] {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let list: [Model] = try modelContext.fetch(fetchDescriptor)
        return list
    }
    
    func fetchDataIds(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [PersistentIdentifier] {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let list: [Model] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.id })
    }

    func fetchCount(predicate: Predicate<Model>? = nil, sortBy: [SortDescriptor<Model>] = []) async throws -> Int {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let count = try modelContext.fetchCount(fetchDescriptor)
        return count
    }

    func remove(predicate: Predicate<Model>? = nil) async throws {
        try modelContext.delete(model: Model.self, where: predicate)
        try await save()
    }
    
    func remove(id: PersistentIdentifier) async {
        if let item = modelContext.model(for: id) as? Model {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
    
    func save() async throws {
        try modelContext.save()
    }

    func saveAndInsertIfNeeded(data: Model, predicate: Predicate<Model>) async throws {
        let descriptor = FetchDescriptor<Model>(predicate: predicate)
        let savedCount = try modelContext.fetchCount(descriptor)

        if savedCount == 0 {
            modelContext.insert(data)
        }
        try await save()
    }
}

/// ```swift
///  // It is important that this actor works as a mutex,
///  // so you must have one instance of the Actor for one container
//   // for it to work correctly.
///  let actor = DataService(container: modelContainer)
///
///  Task {
///      let data: [MyModel] = try? await actor.fetchData()
///  }
///  ```
@available(iOS 17, *)
@ModelActor
actor DataService<Model, SendableModel> where Model: PersistentModelProtocol, SendableModel: SendableModelProtocol {}

extension DataService: DataServiceSendableProtocol {
    
    func fetchDataVMs(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [SendableModel] {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let list: [Model] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.sendableModel as! SendableModel })
    }
    
    func insert(data: SendableModel) async {
        modelContext.insert(data.persistentModel)
        try? modelContext.save()
    }
}
