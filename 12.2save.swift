//
//  12.2save.swift
//  12.01
//
//  Created by Thomas Amosson on 2023.12.02.
//


 
 /*
 
 //CERTIFIED FRESH 12/2

 import SwiftUI
 import AVKit
 import Foundation
 import Combine


 // Struct to hold all the file names
 struct FileNames {
     static let artImage = "juiceArt"
     static let JSON = "Well"
     static let vidMp4 = "notAfraidVid"
 }


 // Song data model
 struct Song: Decodable {
     let title: String
     let artist: String
     let album: String
     let release_date: String
     let description: String
     let bgColor: String
     let textColors: TextColors
     let songDuration: Int
     let lyrics_with_timestamps: [Lyric]
     let annotations_with_timestamps: [Annotation]
 }

 // Text color data model
 struct TextColors: Decodable {
     let textColor1: String
     let textColor2: String
     let textColor3: String
     let textColor4: String
 }

 // Lyric data model
 struct Lyric: Decodable, Identifiable {
     let id: UUID
     let lyric: String
     let timestamp: Double
 }

 // Annotation data model
 struct Annotation: Decodable, Identifiable {
     let id: UUID
     let annotation: String
     let timestamp: Double
 }

 // Function to load song data from JSON
 func loadSongData() -> Song {
     let url = Bundle.main.url(forResource: FileNames.JSON, withExtension: "json")!

     do {
         let data = try Data(contentsOf: url)
         let decoder = JSONDecoder()
         let songData = try decoder.decode(Song.self, from: data)
         return songData
     } catch {
         print("Error loading song data: \(error)")
         return Song(title: "", artist: "", album: "", release_date: "", description: "", bgColor: "", textColors: TextColors(textColor1: "", textColor2: "", textColor3: "", textColor4: ""), songDuration: 0, lyrics_with_timestamps: [], annotations_with_timestamps: [])
     }
 }

 // Color extension for hex color support
 extension Color {
 init(_ hex: String) {
     let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
     var int: UInt64 = 0
     Scanner(string: hex).scanHexInt64(&int)
     let r, g, b, a: UInt64
     switch hex.count {
     case 3: // RGB (12-bit)
         (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
     case 6: // RGB (24-bit)
         (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
     case 8: // ARGB (32-bit)
         (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
     default:
         (r, g, b, a) = (0, 0, 0, 0) // Default to black if invalid hex string
     }
     self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
 }
 }

 // ObservableAVPlayer for managing video playback
 class ObservableAVPlayer: ObservableObject {
     @Published var player: AVPlayer?

     init(filename: String, fileExtension: String) {
             // Use FileNames struct to access file names
             if let url = Bundle.main.url(forResource: FileNames.vidMp4, withExtension: fileExtension) {
             print("URL is valid: \(url)") // Debugging
             self.player = AVPlayer(url: url)
             self.player?.isMuted = true // Mute the audio
             self.player?.play()

             NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                 self.player?.seek(to: .zero)
                 self.player?.play()
             }
         } else {
             print("Invalid URL") // Debugging
         }
     }

     deinit {
         NotificationCenter.default.removeObserver(self)
     }
 }

 struct TopLeftVideoView: View {
     @ObservedObject var videoPlayer: ObservableAVPlayer
     var bgColor: Color
     
     var body: some View {
         ZStack {
             bgColor.edgesIgnoringSafeArea(.all)
             if let player = videoPlayer.player {
                 VideoPlayer(player: player)
                     .frame(width: UIScreen.main.bounds.width / 2.4, height: UIScreen.main.bounds.width / 2.4)
                     .aspectRatio(contentMode: .fill)
                     .edgesIgnoringSafeArea(.all)
                     .position(x: UIScreen.main.bounds.width / 2.5, y: UIScreen.main.bounds.width / 2.4 / 2)
                     .clipShape(RoundedRectangle(cornerRadius: 26)) // Rounded corners
                     .shadow(color: Color.black.opacity(0.8), radius: 12, x: 7, y: 6) // 3D effect
                     .overlay(
                         LinearGradient(
                             gradient: Gradient(stops: [
                                 .init(color: Color.clear, location: 0),
                                 .init(color: bgColor, location: 1.0)
                             ]),
                             startPoint: UnitPoint(x: 2/3, y: 2/3),
                             endPoint: .bottom
                         )
                     )
                     .opacity(0.5) // Adjust transparency here
             }
         }
     }
 }

 struct ModernProgressViewStyle: ProgressViewStyle {
     var gradientColors: [Color]
     var trackColor: Color
     var cornerRadius: CGFloat
     var padding: CGFloat = 10 // Add a padding property
     
     func makeBody(configuration: Configuration) -> some View {
         let gradient = LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
         
         return VStack { // Wrap GeometryReader in VStack
             GeometryReader { geometry in
                 ZStack(alignment: .leading) {
                     // Background track
                     Capsule()
                         .fill(trackColor.opacity(0.2))
                         .frame(height: 11)

                     // Foreground track with gradient
                     Capsule()
                         .fill(gradient)
                         .frame(width: (geometry.size.width - 2 * padding) * CGFloat(configuration.fractionCompleted ?? 0), height: 10) // Subtract padding from total width
                 }
                 .cornerRadius(cornerRadius)
                 .padding(.horizontal, padding) // Apply padding to the ZStack
             }
         }
     }
 }


 struct AnnotationTimelineView: View {
     let annotations: [Annotation]
     let songDuration: Int
     let textColors: TextColors
     let currentTime: Double
     let currentAnnotationId: UUID?
     let song: Song
     let padding: CGFloat = 20 // The horizontal padding for the view

     // New padding values for fine-tuning the layout
     let outerPadding: CGFloat = 10 // Padding around the outer edge of the RoundedRectangle
     let innerPadding: CGFloat = 2  // Padding between the timeline and the edge of the RoundedRectangle

     var body: some View {
         GeometryReader { geometry in
             VStack(spacing: 0) {
                 // Progress Bar with gradient colors
                 ProgressView(value: currentTime, total: Double(songDuration) / 1000.0)
                     .progressViewStyle(ModernProgressViewStyle(
                         gradientColors: [Color(textColors.textColor1), Color(textColors.textColor2)],
                         trackColor: Color(textColors.textColor3),
                         cornerRadius: 6,
                         padding: padding // Your existing padding
                     ))
                     // Apply the inner horizontal padding to the ProgressView
                     .padding([.leading, .trailing], innerPadding)

                 // Marker Area
                 ZStack(alignment: .leading) {
                     ForEach(annotations) { annotation in
                         AnnotationMarkerView(
                             annotation: annotation,
                             textColors: textColors,
                             isActive: annotation.id == currentAnnotationId
                         )
                         // Adjust the marker position within the ZStack, considering the inner padding
                         .position(x: self.calculatePosition(for: annotation, in: geometry.size.width - (innerPadding * 1.5)), y: 5)
                     }
                 }
                 // Apply the inner horizontal padding to the ZStack
                 .padding([.leading, .trailing], innerPadding)
             }
             // Apply the outer padding to the VStack, and wrap it with a RoundedRectangle background
             .padding(.horizontal, outerPadding)
             .background(
                 RoundedRectangle(cornerRadius: 12)
                     .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                     .shadow(radius: 5) // A subtle shadow for depth
             )
         }
         .background(Color(song.bgColor)) // The background color for the whole view
     }

     // Calculate the horizontal position of each marker
     private func calculatePosition(for annotation: Annotation, in totalWidth: CGFloat) -> CGFloat {
         let songDurationInSeconds = CGFloat(songDuration) / 1000.0
         let annotationTimestampInSeconds = CGFloat(annotation.timestamp)
         let positionRatio = annotationTimestampInSeconds / songDurationInSeconds
         // Adjust the position calculation to account for the inner padding
         let position = positionRatio * (totalWidth - (innerPadding * 2)) + innerPadding
         return position
     }
 }

 struct AnnotationMarkerView: View {
     let annotation: Annotation
     let textColors: TextColors
     let isActive: Bool

     var body: some View {
         ZStack {
             Circle()
                 .fill(isActive ? Color.yellow : Color(textColors.textColor4))
                 .frame(width: isActive ? 25 : 20, height: isActive ? 25 : 20)
                 .overlay(
                     Circle()
                         .stroke(Color.white, lineWidth: isActive ? 3 : 1)
                 )
                 .shadow(color: isActive ? Color.yellow.opacity(0.6) : Color.black.opacity(0.5), radius: isActive ? 3 : 1, x: 0, y: 1)
                 .scaleEffect(isActive ? 1.2 : 1.0)
                 .animation(.easeInOut(duration: 0.5), value: isActive)
         }
     }
 }

 struct TitleView: View {
     let song: Song
     @Binding var elapsedTime: Float
     
     var body: some View {
         VStack {
             HStack(alignment: .top) { // Align to the top
                 Image(FileNames.artImage) // Ensure FileNames.artImage is correctly defined and accessible
                     .resizable()
                     .frame(width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8.1)
                     .clipShape(RoundedRectangle(cornerRadius: 20))
                     .padding(.leading, 4) // Reduced padding to bring it closer to the left edge
                 
                 VStack(alignment: .leading, spacing: 0) {
                     Text(song.title)
                         .font(.largeTitle)
                         .fontWeight(.bold)
                         .foregroundColor(Color(song.textColors.textColor1))
                     
                     Text(song.artist)
                         .font(.title)
                         .fontWeight(.semibold)
                         .foregroundColor(Color(song.textColors.textColor2))
                     
                     Text(song.album)
                         .font(.title3)
                         .foregroundColor(Color(song.textColors.textColor3))
                     
                     Text(String(song.release_date.prefix(4)))
                         .font(.subheadline)
                         .foregroundColor(Color(song.textColors.textColor4))
                     
                     Text(song.description)
                         .font(.system(size: 18))
                         .multilineTextAlignment(.center)
                         .lineLimit(nil) // Allowing unlimited lines for the description
                     //.padding()
                 }
                 .padding(.leading, 8)
                 Spacer()
             }
             .frame(height: UIScreen.main.bounds.width / 8 + 20)
             .background(
                 RoundedRectangle(cornerRadius: 15)
                     .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.3)]), startPoint: .bottom, endPoint: .top))
                     .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 10)
             )
             .cornerRadius(10)
         }
     }
     
     struct SongView: View {
         @State private var song = loadSongData()
         @State private var currentLyricId: UUID?
         @State private var currentAnnotationId: UUID?
         @State private var currentTime: Double = 0.0
         @State private var timer: Timer? = nil
         @State private var nextAnnotationTime: Double?
         @State private var currentAnnotationStartTime: Double? = nil
         @State private var annotationQueue: [Annotation] = []
         @State private var elapsedTime: Float = 0.0 // New state for elapsedTime
         @ObservedObject var videoPlayer = ObservableAVPlayer(filename: FileNames.vidMp4, fileExtension: "mp4")


         var body: some View {
             GeometryReader { geometry in
                 VStack {
                     //TopLeftVideoView(videoPlayer: videoPlayer, bgColor: Color(song.bgColor))
                                         //.frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                     TitleView(song: song, elapsedTime: $elapsedTime)

                     // Lyrics display with scrolling centered on the current lyric
                     ScrollViewReader { scrollView in
                         ScrollView {
                             VStack(alignment: .center) {
                                 ForEach(Array(song.lyrics_with_timestamps.enumerated()), id: \.element.id) { index, lyric in
                                     lyricView(lyric, index: index, currentLyricId: currentLyricId)
                                 }
                             }
                             .onChange(of: currentLyricId) { _ in
                                 scrollToCurrentLyric(with: scrollView)
                             }
                         }
                         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                         .offset(y: 100)
                         .offset(x: 50)
                         .background(
                             Color(song.bgColor).overlay(
                                 Image(uiImage: UIImage(ciImage: (CIFilter(name: "CIHatchedScreen")?.outputImage ?? CIImage())))
                                     .resizable()
                                     .opacity(0.8)
                             )
                         )
                     }
                     .frame(height: geometry.size.height * 0.4) // Adjust the height as needed

                     // Enhanced Annotations display with smooth transitions
                     VStack {
                         Spacer()
                         if let annotation = song.annotations_with_timestamps.first(where: { $0.id == currentAnnotationId }) {
                             Text(annotation.annotation)
                                 .frame(maxWidth: .infinity, alignment: .trailing)
                                 .padding()
                                 .background(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.07)]), startPoint: .top, endPoint: .bottom))
                                 .cornerRadius(15)
                                 .shadow(radius: 10)
                                 .font(.system(size: 24, weight: .bold, design: .rounded))
                                 .foregroundColor(Color(song.textColors.textColor2))
                                 .shadow(color: .black, radius: 1)
                                 .transition(AnyTransition.scale.combined(with: .opacity))
                                 .animation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 1.5))
                         }
                         Spacer()
                     }
                     .frame(width: geometry.size.width * 0.5, height: geometry.size.height / 3)
                     .offset(x: geometry.size.width / 5, y: -geometry.size.height / 4)

                     // Annotation timeline and display at the very bottom
                     AnnotationTimelineView(
                         annotations: song.annotations_with_timestamps,
                         songDuration: song.songDuration,
                         textColors: song.textColors,
                         currentTime: currentTime,
                         currentAnnotationId: currentAnnotationId,
                         song: song
                     )
                     .frame(height: 45)
                     .padding(.bottom)
                     Spacer()
                 }
                 .background(Color(song.bgColor))
                 .edgesIgnoringSafeArea(.all)
                 .onAppear {
                     setupTimer()
                 }
                 .onDisappear {
                     self.timer?.invalidate()
                     self.timer = nil
                 }
             }
         }

         // ... existing functions ...
     
         private func lyricView(_ lyric: Lyric, index: Int, currentLyricId: UUID?) -> some View {
             Text(lyric.lyric)
                 .id(lyric.id)
                 .padding(.vertical, currentLyricId == lyric.id ? 3 : 1)
                 .background(currentLyricId == lyric.id ? Color.yellow.opacity(0.2) : Color.clear)
                 .foregroundColor(Color(song.textColors.textColor2))
                 .font(.system(size: 18, weight: currentLyricId == lyric.id ? .bold : .medium, design: .rounded))
                 .border(Color.gray, width: currentLyricId == lyric.id ? 1 : 0.5)
                 .cornerRadius(5)
                 .blur(radius: blurRadiusForIndex(index, currentIndex: song.lyrics_with_timestamps.firstIndex(where: { $0.id == currentLyricId }) ?? 0))
                 .scaleEffect(currentLyricId == lyric.id ? 1.12 : 1.0)
                 .shadow(color: .black, radius: 0.2, x: 2, y: 2)
         }
         
         private func scrollToCurrentLyric(with scrollView: ScrollViewProxy) {
             if let currentLyricId = currentLyricId {
                 withAnimation(.easeInOut(duration: 0.5)) {
                     scrollView.scrollTo(currentLyricId, anchor: .center)
                 }
             }
         }
         
         private func setupTimer() {
             self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                 self.currentTime += 0.1
                 self.updateLyrics()
                 self.updateAnnotations()
             }
         }
         
         private func blurRadiusForIndex(_ index: Int, currentIndex: Int) -> CGFloat {
             let distance = abs(currentIndex - index)
             switch distance {
             case 0...2:
                 return 0 // No blur for current lyric and lyrics close to it
             default:
                 return CGFloat(distance - 2) * 1.5 // Increasing blur with distance
             }
         }
         
         private func updateLyrics() {
             let nearestLyric = song.lyrics_with_timestamps.min(by: { abs($0.timestamp - currentTime) < abs($1.timestamp - currentTime) })
             if let lyric = nearestLyric, lyric.timestamp <= currentTime {
                 if currentLyricId != lyric.id {
                     currentLyricId = lyric.id
                     print("Current lyric updated to: \(lyric.lyric)")
                 }
             }
         }
         
         // Helper functions
         
         private func updateAnnotations() {
             if let currentAnnotation = song.annotations_with_timestamps.first(where: { $0.id == currentAnnotationId }),
                let startTime = currentAnnotationStartTime,
                currentTime - startTime < calculateDisplayDuration(for: currentAnnotation) {
                 return
             }
             
             currentAnnotationId = nil
             currentAnnotationStartTime = nil
             displayNextAnnotationFromQueue()
             queueUpcomingAnnotations()
         }
         
         private func calculateDisplayDuration(for annotation: Annotation) -> Double {
             let secondsPerCharacter = 0.06
             return Double(annotation.annotation.count) * secondsPerCharacter
         }
         
         private func queueUpcomingAnnotations() {
             let upcomingAnnotations = song.annotations_with_timestamps.filter { annotation in
                 annotation.timestamp > currentTime && !annotationQueue.contains(where: { $0.id == annotation.id })
             }
             
             annotationQueue.append(contentsOf: upcomingAnnotations)
             annotationQueue.sort(by: { $0.timestamp < $1.timestamp })
         }
         
         private func displayNextAnnotationFromQueue() {
             if let nextAnnotation = annotationQueue.first, currentTime >= nextAnnotation.timestamp {
                 currentAnnotationId = nextAnnotation.id
                 currentAnnotationStartTime = currentTime
                 annotationQueue.removeFirst()
             }
         }
     }
     
     @main
     struct _2_01App: App {
         var body: some Scene {
             WindowGroup {
                 SongView()
             }
         }
     }
 }

 */
