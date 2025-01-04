//
//  WorkflowListViewModelTests.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/01/2025.
//

//import Quick
//import Nimble
//import SwiftData
//@testable import AgentOrange
//import Factory
//
//actor MockDataService: PersistentDataManagerProtocol {
//    func fetchAllWorkflows() async -> [Workflow] {
//        
//    }
//    
//    func fetchWorkflow(for name: String) async -> Workflow? {
//        
//    }
//        
//    var workflows: [Workflow] = []
//    var addCalled = false
//    var deleteCalled = false
//    var deleteAllWorkflowsCalled = false
//    var lastAddedWorkflow: Workflow?
//    
//    func add(workflow: Workflow) async {
//        addCalled = true
//        lastAddedWorkflow = workflow
//        workflows.append(workflow)
//    }
//    
//    func delete(workflow: Workflow) async {
//        deleteCalled = true
//        workflows.removeAll { $0.id == workflow.id }
//    }
//    
//    func fetchWorkflows() async -> [Workflow] {
//        return workflows
//    }
//    
//    func deleteAllWorkflows() async {
//        deleteAllWorkflowsCalled = true
//        workflows.removeAll()
//    }
//}
//
//final class WorkflowListViewModelTests: QuickSpec {
//    
//    override class func spec() {
//        // Create a mock for PersistentWorkflowDataManagerProtocol
//        
//        describe("GIVEN a WorkflowListViewModel") {
//            var viewModel: WorkflowListViewModel!
//            
//            beforeEach {
//                // Mock the dependency injection in the 'init'
//                Container.shared.dataService.register { _ in
//                    MockDataService()
//                }
//                
//                // Create a dummy ModelContext
//                let modelContainer = try! ModelContainer(for: Workflow.self, configurations: .init(isStoredInMemoryOnly: true))
//                viewModel = WorkflowListViewModel(modelContext: modelContainer.mainContext)
//            }
//            
//            context("WHEN addWorkflow() is called") {
//                it("THEN a new workflow should be added via the data service") {
//                    await viewModel.addWorkflow()
//                    expect(mockDataService.addCalled).to(beTrue())
//                    expect(mockDataService.workflows.count).to(equal(1))
//                    expect(mockDataService.workflows.first?.name).to(beEmpty())
//                }
//            }
//            
//            context("WHEN delete(workflow:) is called") {
//                it("THEN the specified workflow should be deleted via the data service") {
//                    // Add an item first to test with
//                    let workflow = Workflow(name: "Test Workflow", timestamp: Date.now, shortDescription: "Desc", commandArrangement: nil)
//                    await mockDataService.add(workflow: workflow)
//                    expect(mockDataService.workflows.count).to(equal(1))
//                    
//                    await viewModel.delete(workflow: workflow)
//                    expect(mockDataService.deleteCalled).to(beTrue())
//                    expect(mockDataService.workflows).to(beEmpty())
//                }
//            }
//            
//            context("WHEN duplicate(workflow:) is called") {
//                it("THEN a duplicated workflow with ' Copy' appended should be added") {
//                    // Add an item first to test with
//                    let workflow = Workflow(name: "Test Workflow", timestamp: Date.now, shortDescription: "Desc", commandArrangement: nil)
//                    await mockDataService.add(workflow: workflow)
//                    expect(mockDataService.workflows.count).to(equal(1))
//                    
//                    await viewModel.duplicate(workflow: workflow)
//                    expect(mockDataService.addCalled).to(beTrue())
//                    expect(mockDataService.workflows.count).to(equal(2))
//                    expect(mockDataService.workflows.last?.name).to(equal("Test Workflow Copy"))
//                }
//            }
//            
//            context("WHEN removeCommands(workflow:) is called") {
//                it("THEN the workflow commandArrangement should be set to nil via the data service") {
//                    // Add an item first to test with
//                    let commandArrangement = CommandArrangement(commands: [Command()])
//                    let workflow = Workflow(name: "Test Workflow", timestamp: Date.now, shortDescription: "Desc", commandArrangement: commandArrangement)
//                    await mockDataService.add(workflow: workflow)
//                    expect(mockDataService.workflows.first?.commandArrangement).toNot(beNil())
//                    
//                    await viewModel.removeCommands(workflow: workflow)
//                    expect(mockDataService.addCalled).to(beTrue())
//                    expect(mockDataService.workflows.first?.commandArrangement).to(beNil())
//                }
//            }
//            
//            context("WHEN deleteAllWorkflows() is called") {
//                it("THEN all workflows should be deleted via the data service") {
//                    // Add some items first to test with
//                    await mockDataService.add(workflow: Workflow(name: "Test Workflow 1", timestamp: Date.now, shortDescription: "Desc", commandArrangement: nil))
//                    await mockDataService.add(workflow: Workflow(name: "Test Workflow 2", timestamp: Date.now, shortDescription: "Desc", commandArrangement: nil))
//                    expect(mockDataService.workflows.count).to(equal(2))
//                    
//                    await viewModel.deleteAllWorkflows()
//                    expect(mockDataService.deleteAllWorkflowsCalled).to(beTrue())
//                    expect(mockDataService.workflows).to(beEmpty())
//                }
//            }
//            
//            context("WHEN initialized") {
//               it("THEN it should have a data service injected") {
//                   expect(viewModel.dataService).toNot(beNil())
//               }
//           }
//        }
//    }
//}
//
