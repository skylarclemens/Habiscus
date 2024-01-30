//
//  HabiscusWidgetBundle.swift
//  HabiscusWidget
//
//  Created by Skylar Clemens on 11/4/23.
//

import WidgetKit
import SwiftUI

@main
struct HabiscusWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabiscusWidget()
        MultiHabitWidget()
    }
}
