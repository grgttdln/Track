//
//  TrackApp.swift
//  Track
//
//  Created by Georgette Dalen on 1/6/26.
//

import SwiftUI
import SwiftData

#if os(macOS)
@main
struct TrackApp: App {
    var body: some Scene {
        MenuBarExtra("Track", systemImage: "square.grid.2x2") {
            SquarePopoverView()
                .frame(width: 500, height: 420)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: TrackTask.self)
    }
}
#endif
