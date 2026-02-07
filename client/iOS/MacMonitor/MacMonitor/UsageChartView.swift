//
//  UsageChartView.swift
//  MacMonitor
//
//  Created on 2026-02-07.
//

import SwiftUI
import DGCharts

struct UsageChartView: View {
    let data: [Double]
    let maxValue: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard data.count >= 2 else { return }
                
                let width = size.width
                let height = size.height
                let spacing = width / CGFloat(max(data.count - 1, 1))
                
                // Create path for line
                var path = Path()
                
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * spacing
                    let normalizedValue = min(max(value, 0), maxValue) / maxValue
                    let y = height - (CGFloat(normalizedValue) * height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                // Draw gradient fill under the line
                var fillPath = path
                if let lastPoint = path.currentPoint {
                    fillPath.addLine(to: CGPoint(x: lastPoint.x, y: height))
                    fillPath.addLine(to: CGPoint(x: 0, y: height))
                    fillPath.closeSubpath()
                }
                
                let gradient = Gradient(colors: [
                    color.opacity(0.3),
                    color.opacity(0.05)
                ])
                
                context.fill(
                    fillPath,
                    with: .linearGradient(
                        gradient,
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: height)
                    )
                )
                
                // Draw the line
                context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: 2
                )
            }
        }
        .frame(height: 60)
    }
}

struct NetworkChartView: View {
    let dataIn: [Double]
    let dataOut: [Double]
    let maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard dataIn.count >= 2 && dataOut.count >= 2 else { return }
                
                let width = size.width
                let height = size.height
                let spacing = width / CGFloat(max(dataIn.count - 1, 1))
                
                // Draw download line (blue)
                var pathIn = Path()
                for (index, value) in dataIn.enumerated() {
                    let x = CGFloat(index) * spacing
                    let normalizedValue = min(max(value, 0), maxValue) / maxValue
                    let y = height - (CGFloat(normalizedValue) * height)
                    
                    if index == 0 {
                        pathIn.move(to: CGPoint(x: x, y: y))
                    } else {
                        pathIn.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                // Draw upload line (purple)
                var pathOut = Path()
                for (index, value) in dataOut.enumerated() {
                    let x = CGFloat(index) * spacing
                    let normalizedValue = min(max(value, 0), maxValue) / maxValue
                    let y = height - (CGFloat(normalizedValue) * height)
                    
                    if index == 0 {
                        pathOut.move(to: CGPoint(x: x, y: y))
                    } else {
                        pathOut.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                // Draw lines
                context.stroke(pathIn, with: .color(.blue), lineWidth: 2)
                context.stroke(pathOut, with: .color(.purple), lineWidth: 2)
            }
        }
        .frame(height: 50)
    }
}
