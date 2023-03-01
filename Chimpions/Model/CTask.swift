//
//  CTask.swift
//  Chimpions
//
//  Created by Nunzio Ricci on 01/03/23.
//

import Foundation

struct CTask: Codable, Identifiable {
    var id = UUID()
    var projectId: UUID
    var duration: TimeInterval
}