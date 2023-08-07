//
//  FileManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/21/23.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
