//
//  MainViewFlow.swift
//  Chimpions
//
//  Created by Bruno De Vivo on 23/02/23.
//

import SwiftUI

struct MainViewFlow: View {
    
    var dayMonth = {
        let date = Date()
        var formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }()
    var dayNameYear = {
        let date = Date()
        var formatter = DateFormatter()
        formatter.dateFormat = "EEEE yyyy"
        return formatter.string(from: date)
    }()
    
    @State var projects: [CProject] = {
        var result: [CProject] = []
        result.append(CProject(name: ""))
        result.append(contentsOf:  PersistencyManager.shared.getAllProjects())
        return result
    }()
    
    @State var tasks: [CTask] = {
        var result: [CTask] = []
        result.append(contentsOf:  PersistencyManager.shared.getAllTasks())
        return result
    }()
    
    @State var displayTimer: Bool = false
    @State var selectedTask: CTask!
    @AppStorage("alreadyOpened") var alreadyOpened: Bool = false
    
    var body: some View {
        if !alreadyOpened {
            Onboarding {
                alreadyOpened = true
            }
        } else if displayTimer {
            TaskTimerDetail(task: selectedTask, displayTimer: $displayTimer)
                .transition(.move(edge: .bottom))
                .onAppear {
                    print(tasks[0])
                }
        } else {
            VStack{
                VStack{
                    HStack {
                        Spacer()
                        VStack{
                            HStack{
                                Text(dayMonth)
                                    .font(.system(size: 44))
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                            }
                            HStack{
                                Text(dayNameYear)
                                    .font(.system(size: 24))
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                            }
                        }
                        .padding(.trailing)
                    }
                    
                    HStack {
                        Text("Your Flow")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Spacer()
                    }
                    .padding(.leading)
                    ZStack {
                        StreamComponent()
                            .opacity(0.15)
                        Carousel(projects) { project in
                            ProjectButtonComponent(kind: project.name == "" ? .empty : .filledClosed, project: project, onTaskAdd: { interval in
                                var task: CTask
                                if let existentTask = PersistencyManager.shared.getAllTasks().first(where: { $0.projectId == project.id }) {
                                    task = existentTask
                                    task.duration += interval
                                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                        tasks[index] = task
                                    }
                                } else {
                                    task = CTask(projectId: project.id, duration: interval)
                                    tasks.append(task)
                                }
                                try? PersistencyManager.shared.save(task: task)
                            }, name: project.name)
                        }
                    }
                    .frame(height: 250)
                    .offset(y: -25)
                    
                }
                .padding(.top, 10)
                
                Spacer(minLength: 80)
                ZStack(alignment: .top) {
                    StreamComponent()
                        .ignoresSafeArea()
                    HStack {
                        Text("Today")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Spacer()
                    }.offset(y: 30)
                    Carousel(tasks) { task in
                        TaskButtonComponent(task: task)
                            .onTapGesture {
                                selectedTask = task
                                displayTimer.toggle()
                            }
                    }
                }
                .offset(y: 50)
                
            }
            .onAppear(){
                print(projects)
            }.animation(.linear, value: projects)
                .transition(.move(edge: .top))
        }
    }
}
    
struct MainViewFlow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MainViewFlow()
                .environmentObject(PersistencyManager.preview)
        }
    }
}
