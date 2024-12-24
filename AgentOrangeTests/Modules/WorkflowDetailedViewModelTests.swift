//
//  WorkflowDetailedViewModelTests.swift
//  AgentOrange
//
//  Created by Paul Leo on 24/12/2024.
//
import Foundation
import Quick
import Nimble
import SwiftData
@testable import AgentOrange // Replace with your actual module name

final class WorkflowDetailedViewModelSpec: QuickSpec {
    
    override class func spec() {
        // MARK: - Mock Setup
        var mockModelContainer: ModelContainer!
        var mockModelContext: ModelContext!
        
        beforeEach {
            let schema = Schema([CDWorkflow.self, CDChatCommand.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            mockModelContainer = try! ModelContainer(for: schema, configurations: configuration)
            mockModelContext = ModelContext(mockModelContainer)
        }
        
        
        // MARK: - Unit Tests
        describe("GIVEN a WorkflowDetailedViewModel") {
            context("WHEN initialized with a workflow") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                }
                
                it("THEN it should have the correct editing and selected workflows") {
                    expect(sut.editingWorkflow.name).to(equal("Initial Workflow"))
                    expect(sut.selectedWorkflow.name).to(equal("Initial Workflow"))
                    expect(sut.editingWorkflow.shortDescription).to(equal("Initial Description"))
                    expect(sut.selectedWorkflow.shortDescription).to(equal("Initial Description"))
                    expect(sut.editingWorkflow.commandIds).to(equal(["command1"]))
                    expect(sut.selectedWorkflow.commandIds).to(equal(["command1"]))
                    expect(sut.isEditing).to(beFalse())
                }
            }
            
            context("WHEN save() is called with a valid workflow") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    sut.editingWorkflow.name = "Edited Workflow"
                    sut.editingWorkflow.shortDescription = "Edited Description"
                    sut.save()
                }
                
                it("THEN it should save the workflow, update the selected workflow, and post a refresh notification") {
                    expect(sut.selectedWorkflow.name).toEventually(equal("Edited Workflow"))
                    expect(sut.selectedWorkflow.shortDescription).toEventually(equal("Edited Description"))
                    expect(sut.errorMessage).to(beNil())
                }
            }
            
            context("WHEN save() is called with an invalid workflow") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    sut.editingWorkflow.name = ""
                    sut.save()
                }
                
                it("THEN it should set an error message") {
                    expect(sut.errorMessage).to(equal("Name, short description and commands are required"))
                }
            }
            
            context("WHEN delete(workflow:) is called") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    sut.delete(workflow: initialWorkflow)
                }
                
                it("THEN it should delete the workflow") {
                    
                }
            }
            
            context("WHEN editBtnPressed() is called for the first time") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    sut.editBtnPressed()
                }
                
                it("THEN it should set isEditing to true") {
                    expect(sut.isEditing).to(beTrue())
                }
            }
            
            context("WHEN editBtnPressed() is called for the second time") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    sut.isEditing = true
                    sut.editBtnPressed()
                }
                
                it("THEN it should set isEditing to false") {
                    expect(sut.isEditing).to(beFalse())
                }
            }
            
            context("WHEN cancelBtnPressed() is called") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                var selectedWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    selectedWorkflow = Workflow(name: "Selected Workflow", timestamp: Date.now, shortDescription: "Selected Description", commandIds: ["command2"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    sut.selectedWorkflow = selectedWorkflow
                    sut.editingWorkflow.name = "Edited Workflow"
                    sut.editingWorkflow.shortDescription = "Edited Description"
                    sut.isEditing = true
                    sut.errorMessage = "An Error"
                    
                    sut.cancelBtnPressed()
                }
                
                it("THEN it should reset isEditing, editingWorkflow, and errorMessage") {
                    expect(sut.isEditing).to(beFalse())
                    expect(sut.editingWorkflow.name).to(equal("Selected Workflow"))
                    expect(sut.editingWorkflow.shortDescription).to(equal("Selected Description"))
                    expect(sut.errorMessage).to(beNil())
                }
            }
            
            context("WHEN getHosts(commands:) is called") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                var mockCommands: [CDChatCommand]!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1", "command2", "command3"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    mockCommands = [
                        CDChatCommand(name: "command1", timestamp: Date.now, prompt: "Prompt 1", shortDescription: "short description 1", host: "http://host1.com"),
                        CDChatCommand(name: "command2", timestamp: Date.now, prompt: "Prompt 2", shortDescription: "short description 2", host: "http://host2.com"),
                        CDChatCommand(name: "command3", timestamp: Date.now, prompt: "Prompt 3", shortDescription: "short description 3", host: "http://host3.com")
                    ]
                }
                
                it("THEN it should return the unique hosts for the workflow commands") {
                    let hosts = sut.getHosts(commands: mockCommands)
                    expect(hosts).to(equal(["http://host1.com", "http://host2.com", "http://host3.com"]))
                }
            }
            
            context("WHEN commands(for:commands:) is called") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                var mockCommands: [CDChatCommand]!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1", "command2", "command3"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    mockCommands = [
                        CDChatCommand(name: "command1", timestamp: Date.now, prompt: "Prompt 1", shortDescription: "short description 1", host: "http://host1.com"),
                        CDChatCommand(name: "command2", timestamp: Date.now, prompt: "Prompt 2", shortDescription: "short description 2", host: "http://host1.com"),
                        CDChatCommand(name: "command3", timestamp: Date.now, prompt: "Prompt 3", shortDescription: "short description 3", host: "http://host1.com")
                    ]
                }
                
                it("THEN it should return commands for a specific host") {
                    let commands = sut.commands(for: "http://host1.com", commands: mockCommands)
                    expect(commands.count).to(equal(3))
                    expect(commands.first?.name).to(equal("command1"))
                    expect(commands.last?.name).to(equal("command3"))
                }
            }
            
            context("WHEN addCommand(command:) is called with a new command") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    let newCommand = ChatCommand(name: "command1", timestamp: Date.now, prompt: "Prompt 1", shortDescription: "short description 1")
                    sut.addCommand(command: newCommand)
                }
                
                it("THEN it should add the command to the workflow") {
                    expect(sut.editingWorkflow.commandIds).to(equal(["command1"]))
                }
            }
            
            context("WHEN addCommand(command:) is called with an existing command") {
                var sut: WorkflowDetailedViewModel!
                var initialWorkflow: Workflow!
                
                beforeEach {
                    initialWorkflow =  Workflow(name: "Initial Workflow", timestamp: Date.now, shortDescription: "Initial Description", commandIds: ["command1"])
                    sut = WorkflowDetailedViewModel(modelContext: mockModelContext, workflow: initialWorkflow)
                    let existingCommand = ChatCommand(name: "command1", timestamp: Date.now, prompt: "Prompt 1", shortDescription: "short description 1")
                    sut.addCommand(command: existingCommand)
                }
                
                it("THEN it should not add the command to the workflow") {
                    expect(sut.editingWorkflow.commandIds).to(equal(["command1"]))
                }
            }
        }
    }
}
