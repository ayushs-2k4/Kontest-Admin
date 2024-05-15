//
//  RotatingMapScreen.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 15/05/24.
//

import MapKit
import SwiftUI

struct ParkingSpot: Identifiable, Hashable {
    var id: String { self.name }
    let name: String
    let location: CLLocation
    var cameraDistance: Double = 1000
}

struct City: Identifiable, Hashable {
    var id: String { self.name }
    let name: String
    let parkingSpots: [ParkingSpot]
}

struct RandomRotatingMapScreen: View {
    let navigationTitle: String?

    var body: some View {
        let cities: [City] = [.cupertino, .london, .sanFrancisco]
        let selectedCity = cities.randomElement()!

        let parkingSpots = selectedCity.parkingSpots
        let selectedParkingSpot = parkingSpots.randomElement()!

        RotatingMapScreen(parkingSpot: selectedParkingSpot)
            .navigationTitle(self.navigationTitle ?? "")
    }
}

struct AboutMeCard: View {
    var body: some View {
        HStack {
            VStack {
                Text("Hi 👋, I'm Ayush Singhal, creator of Kontest App")
                HStack(spacing: 0) {
                    Label {
                        Link("ayushs-2k4", destination: URL(string: "http://github.com/ayushs-2k4/")!)
                    } icon: {
                        Image(.githubLogo)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .imageScale(.small)
                    }
                }
                .frame(height: 20)
            }

            Image(.myMemoji)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }
}

struct RotatingMapScreen: View {
    let parkingSpot: ParkingSpot

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { context in
                VStack {
                    let seconds = context.date.timeIntervalSince1970
                    let rotationPeriod = 240.0
                    let headingDelta = seconds.percent(truncation: rotationPeriod)
                    let pitchPeriod = 60.0
                    let pitchDelta = seconds
                        .percent(truncation: pitchPeriod)
                        .symmetricEaseInOut()

                    let viewWidthPercent = (350.0 ... 1000).percent(for: proxy.size.width)
                    let distanceMultiplier = (1 - viewWidthPercent) * 0.5 + 1

                    RotatingMapView(
                        coordinates: self.parkingSpot.location,
                        distance: distanceMultiplier * self.parkingSpot.cameraDistance,
                        pitch: (50 ... 60).value(percent: pitchDelta),
                        heading: headingDelta * 360
                    )
                }
            }
        }
        #if os(macOS)
        .overlay(alignment: .top) {
            AboutMeCard()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
        }
        #else
        .overlay(alignment: .bottom) {
                AboutMeCard()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
            }
        #endif
    }
}

struct RotatingMapView: View {
    let coordinates: CLLocation
    let distance: Double
    let pitch: Double
    let heading: CGFloat

    @State private var cameraPosition: MapCameraPosition

    init(coordinates: CLLocation, distance: Double, pitch: Double, heading: CGFloat) {
        self.coordinates = coordinates
        self.distance = distance
        self.pitch = pitch
        self.heading = heading

        self._cameraPosition = State(wrappedValue: .camera(MapCamera(centerCoordinate: coordinates.coordinate, distance: distance, heading: heading, pitch: pitch)))
    }

    var body: some View {
        Map(position: self.$cameraPosition, interactionModes: [])
            .onChange(of: self.heading) { _, _ in
                self.cameraPosition = .camera(MapCamera(centerCoordinate: self.coordinates.coordinate, distance: self.distance, heading: self.heading, pitch: self.pitch))
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
    }
}

#Preview("RotatingMapScreen") {
    RotatingMapScreen(parkingSpot: City.cupertino.parkingSpots[0])
}

#Preview("RandomRotatingMapScreen") {
    RandomRotatingMapScreen(navigationTitle: "RandomRotatingMapScreen")
}

public extension ClosedRange where Bound: BinaryFloatingPoint {
    func value(percent: Bound, clamped: Bool = true) -> Bound {
        var percent = percent
        if clamped {
            percent = Swift.min(Swift.max(percent, 0), 1)
        }
        return (1 - percent) * lowerBound + percent * upperBound
    }

    func percent(for value: Bound, clamped: Bool = true) -> Bound {
        var result = (value - lowerBound) / (upperBound - value)
        if clamped {
            result = Swift.min(Swift.max(result, 0), 1)
        }
        return result
    }
}

public extension BinaryFloatingPoint {
    func easeInOut(clamped: Bool = true) -> Self {
        assert(self.isFinite)
        let timing = clamped ? min(max(self, 0), 1) : self
        return timing * timing * (3.0 - 2.0 * timing)
    }

    /// Takes a value from 0 to 1 and returns a value that starts at 0, eases into 1, and eases back into 0.
    ///
    /// For example, the following inputs generate these outputs:
    /// Input  | Output
    /// --- | ---
    /// `0` | `0`
    /// `0.25` | `0.5`
    /// `0.5` | `1`
    /// `0.75` | `0.5`
    /// `1` | `0`
    ///
    /// > Important: Only call this method on a finite number.
    /// - Parameter clamped: Ignores values outside `0...1`, defaults to `true`.
    /// - Returns: A value that is easing from 0 to 1 and back to 0.
    func symmetricEaseInOut(clamped: Bool = true) -> Self {
        assert(self.isFinite)
        let timing = clamped ? min(max(self, 0), 1) : self
        if timing <= 0.5 {
            return (timing * 2).easeInOut(clamped: clamped)
        } else {
            return (2 - (timing * 2)).easeInOut(clamped: clamped)
        }
    }

    func percent(truncation: Self) -> Self {
        assert(self.isFinite)
        assert(!truncation.isZero && truncation.isFinite)
        return self.truncatingRemainder(dividingBy: truncation) / truncation
    }
}

extension City {
    static let sanFrancisco = City(
        name: "San Francisco",
        parkingSpots: [
            ParkingSpot(
                name: "Coit Tower",
                location: CLLocation(latitude: 37.8024, longitude: -122.4058),
                cameraDistance: 300
            ),
            ParkingSpot(
                name: "Fisherman's Wharf",
                location: CLLocation(latitude: 37.8099, longitude: -122.4103),
                cameraDistance: 700
            ),
            ParkingSpot(
                name: "Ferry Building",
                location: CLLocation(latitude: 37.7956, longitude: -122.3935),
                cameraDistance: 450
            ),
            ParkingSpot(
                name: "Golden Gate Bridge",
                location: CLLocation(latitude: 37.8199, longitude: -122.4783),
                cameraDistance: 2000
            ),
            ParkingSpot(
                name: "Oracle Park",
                location: CLLocation(latitude: 37.7786, longitude: -122.3893),
                cameraDistance: 650
            ),
            ParkingSpot(
                name: "The Castro Theatre",
                location: CLLocation(latitude: 37.7609, longitude: -122.4350),
                cameraDistance: 400
            ),
            ParkingSpot(
                name: "Sutro Tower",
                location: CLLocation(latitude: 37.7552, longitude: -122.4528)
            ),
            ParkingSpot(
                name: "Bay Bridge",
                location: CLLocation(latitude: 37.7983, longitude: -122.3778)
            )
        ]
    )

    static let cupertino = City(
        name: "Cupertino",
        parkingSpots: [
            ParkingSpot(
                name: "Apple Park",
                location: CLLocation(latitude: 37.3348, longitude: -122.0090),
                cameraDistance: 1100
            ),
            ParkingSpot(
                name: "Infinite Loop",
                location: CLLocation(latitude: 37.3317, longitude: -122.0302)
            )
        ]
    )

    static let london = City(
        name: "London",
        parkingSpots: [
            ParkingSpot(
                name: "Big Ben",
                location: CLLocation(latitude: 51.4994, longitude: -0.1245),
                cameraDistance: 850
            ),
            ParkingSpot(
                name: "Buckingham Palace",
                location: CLLocation(latitude: 51.5014, longitude: -0.1419),
                cameraDistance: 750
            ),
            ParkingSpot(
                name: "Marble Arch",
                location: CLLocation(latitude: 51.5131, longitude: -0.1589)
            ),
            ParkingSpot(
                name: "Piccadilly Circus",
                location: CLLocation(latitude: 51.510067, longitude: -0.133869)
            ),
            ParkingSpot(
                name: "Shakespeare's Globe",
                location: CLLocation(latitude: 51.5081, longitude: -0.0972)
            ),
            ParkingSpot(
                name: "Tower Bridge",
                location: CLLocation(latitude: 51.5055, longitude: -0.0754)
            )
        ]
    )

    static let all = [cupertino, sanFrancisco, london]

    static func identified(by id: City.ID) -> City {
        guard let result = all.first(where: { $0.id == id }) else {
            fatalError("Unknown City ID: \(id)")
        }
        return result
    }
}
