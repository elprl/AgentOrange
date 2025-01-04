//
//  WorkflowDetailedViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 22/12/2024.
//

import SwiftUI
import SwiftData
import Factory

struct CommandArrangement: Codable {
    var column: Int
    var row: Int
    var commandId: String
}

@Observable
@MainActor
final class WorkflowDetailedViewModel {
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentWorkflowDataManagerProtocol & PersistentCommandDataManagerProtocol
    var editingWorkflow: Workflow
    var selectedWorkflow: Workflow
    var isEditing: Bool = false
    var errorMessage: String?
    var commandIds: [[String]] = [[]]
    var selectedColumn: Int = 0
    
    var tracks: Int {
        return commandIds.count
    }
    
    init(modelContext: ModelContext, workflow: Workflow) {
        editingWorkflow = workflow
        selectedWorkflow = workflow
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
        processOrder()
    }
    
    func save() {
        if validateCommand() {
            errorMessage = nil
            Task {
                editingWorkflow.commandArrangement = getArrangementStr()
                await dataService.add(workflow: editingWorkflow)
                self.selectedWorkflow = self.editingWorkflow
                NotificationCenter.default.post(name: NSNotification.Name("refreshWorkflows"), object: nil)
            }
        } else {
            errorMessage = "Name, short description and commands are required"
        }
    }
    
    func addTrack() {
        if commandIds.count < 4 {            
            commandIds.append([])
        }
    }
    
    func removeTrack() {
        if commandIds.count > 1 {
            commandIds.removeLast()
        }
    }
    
    private func validateCommand() -> Bool {
        return !editingWorkflow.name.isEmpty && !editingWorkflow.shortDescription.isEmpty
    }
    
    func delete(workflow: Workflow) {
        Task {
            await dataService.delete(workflow: workflow)
        }
    }
    
    func editBtnPressed() {
        if isEditing {
            save()
            isEditing = false
        } else {
            isEditing = true
        }
    }
    
    func cancelBtnPressed() {
        isEditing = false
        editingWorkflow = selectedWorkflow
        errorMessage = nil
    }
    
    func getCommands(for column: Int, commands: [CDChatCommand]) -> [CDChatCommand] {
        var filteredCommands: [CDChatCommand] = []
        if column < commandIds.count {
            let commandSet = commandIds[column]
            
            commandSet.forEach { id in
                if let command = commands.first(where: { $0.name == id }) {
                    filteredCommands.append(command)
                } else if id == "<wait>" {
                    filteredCommands.append(CDChatCommand(name: "<wait>", prompt: "", shortDescription: "Waits for row to complete", role: "", model: "", host: "", type: .reviewer))
                }
            }
        }
        return filteredCommands
    }
        
    private func processOrder() {
        guard let commandArrangementStr = editingWorkflow.commandArrangement else { return }
        // convert json str to CommandArrangement
        do {
            let data = Data(commandArrangementStr.utf8)
            let decoder = JSONDecoder()
            commandIds = try decoder.decode([[String]].self, from: data)
            commandIds = commandIds.filter { !$0.isEmpty }
        } catch {
            Log.pres.error("Error decoding command arrangement: \(error)")
        }
    }
    
    private func getArrangementStr() -> String? {
        do {
            if commandIds.isEmpty {
                return nil
            }
            let encoder = JSONEncoder()
            let data = try encoder.encode(commandIds.filter { !$0.isEmpty })
            return String(data: data, encoding: .utf8)
        } catch {
            Log.pres.error("Error encoding command arrangement: \(error)")
            return nil
        }
    }
    
    func addToWorkflow(command: ChatCommand) {
        if selectedColumn < commandIds.count {
            var commandSet = commandIds[selectedColumn]
            commandSet.append(command.name)
            commandIds[selectedColumn] = commandSet
        } else {
            commandIds.append([command.name])
        }
    }
    
    func deleteCommand(column: Int, indexSet: IndexSet) {
        if column < commandIds.count {
            var commandSet = commandIds[column]
            commandSet.remove(atOffsets: indexSet)
            commandIds[column] = commandSet
        }
    }
    
    func moveCommand(column: Int, from: IndexSet, to: Int) {
        if column < commandIds.count {
            var commandSet = commandIds[column]
            commandSet.move(fromOffsets: from, toOffset: to)
            commandIds[column] = commandSet
        }
    }
    
    func addWaitStep() {
        if selectedColumn < commandIds.count {
            var commandSet = commandIds[selectedColumn]
            commandSet.append("<wait>")
            commandIds[selectedColumn] = commandSet
        }
    }
}

extension WorkflowDetailedViewModel {
    static func mock() -> WorkflowDetailedViewModel {
        let viewModel = WorkflowDetailedViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext,
                                                  workflow: Workflow(name: "Workflow", timestamp: Date.now, shortDescription: "Workflow Description", commandArrangement: "command1,command2"))
        return viewModel
    }
}

