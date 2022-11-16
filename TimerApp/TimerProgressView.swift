//
//  TimerProgressView.swift
//  TimerApp
//
//  Created by D4ttatraya on 16/11/22.
//

import SwiftUI

fileprivate let ThemeColour = Color.orange

struct TimerProgressView: View {
    let progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    ThemeColour.opacity(0.25),
                    lineWidth: 30
                )
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    ThemeColour,
                    style: StrokeStyle(
                        lineWidth: 30,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)

        }
    }
}

struct TimerProgressView_Previews: PreviewProvider {
    static var previews: some View {
        TimerProgressView(progress: 0.5)
    }
}
