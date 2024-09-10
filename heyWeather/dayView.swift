//
//  dayView.swift
//  heyWeather
//
//  Created by Omid Zaheri on 9/10/24.
//

import SwiftUI

struct dayView: View {
    
    let sunriseTime: Double = 5.0
    let sunsetTime: Double = 18.0
    
    @State private var currentTime: Double = 6.0
    
    var body: some View {
        ZStack {
            Color(.blue)
                .ignoresSafeArea()
            VStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .frame(width: 360, height: 160)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "sunrise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.purple)
                                VStack {
                                    Text("Sunrise")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 10))
                                    Text(formatTime(sunriseTime))
                                        .font(.system(size: 14))
                                }
                                .padding(.trailing)
                                Spacer()
                                VStack {
                                    HStack {
                                        VStack {
                                            Text("Sunset")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 10))
                                            Text(formatTime(sunsetTime))
                                                .font(.system(size: 14))
                                        }
                                        Image(systemName: "sunset")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.purple)
                                    }
                                }
                            }
                            .padding()
                        }
                    )
                    .overlay(
                        GeometryReader { geometry in
                            let sunPositionX = calculateSunPosition(in: geometry.size.width)
                            let sunY = calculateY(at: sunPositionX, in: geometry.size.width, geometry: geometry)

                            ZStack {
                                Path { path in
                                    let startX = geometry.size.width * 0.1
                                    let endX = geometry.size.width * 0.9
                                    let midY = geometry.size.height / 2
                                    
                                    path.move(to: CGPoint(x: startX, y: midY))
                                    
                                    for x in stride(from: startX, to: endX, by: 1.0) {
                                        let y = midY - 20 * sin((x - startX) * .pi / (endX - startX))
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                                .stroke(Color.secondary, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))

                                Image(systemName: "sun.max.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                    .position(x: sunPositionX, y: sunY)
                                    .animation(.linear(duration: 0.1), value: currentTime)

                                Path { path in
                                    let startY = geometry.size.height / 2
                                    path.move(to: CGPoint(x: sunPositionX, y: sunY))
                                    path.addLine(to: CGPoint(x: sunPositionX, y: startY))
                                }
                                .stroke(Color.purple, lineWidth: 2)
                            }
                        }
                        .frame(height: 200)
                    )
            }
        }
        .onAppear {
            updateCurrentTime()
            startAnimation()
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let hour = Int(time)
        let minute = (time - Double(hour)) * 60
        return String(format: "%02d:%02d", hour, Int(minute))
    }
    
    func calculateSunPosition(in width: CGFloat) -> CGFloat {
        let totalWidth = width * 0.8
        let sunriseX = totalWidth * ((sunriseTime - 6) / (sunsetTime - sunriseTime))
        let sunsetX = totalWidth * ((sunsetTime - 6) / (sunsetTime - sunriseTime))
        let currentX = sunriseX + (sunsetX - sunriseX) * ((currentTime - sunriseTime) / (sunsetTime - sunriseTime))
        return currentX + (width * 0.1)
    }
    
    func calculateY(at x: CGFloat, in width: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let midY = geometry.size.height / 2
        let totalWidth = width * 0.8
        let startX = width * 0.1
        let endX = width * 0.9
        
        return midY - 20 * sin((x - startX) * .pi / (endX - startX))
    }

    func startAnimation() {
        withAnimation(.linear(duration: 12)) {
            currentTime = sunsetTime
        }
    }
    
    func updateCurrentTime() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let currentHour = Calendar.current.component(.hour, from: Date())
            let currentMinute = Calendar.current.component(.minute, from: Date())
            let totalHours = Double(currentHour) + Double(currentMinute) / 60.0
            currentTime = min(max(totalHours, sunriseTime), sunsetTime)
        }
    }
}

#Preview {
    dayView()
}
