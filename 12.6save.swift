//
//  12.6save.swift
//  12.01
//
//  Created by Thomas Amosson on 2023.12.06.
//

/*
 
 LOADING ANIMATION FOR LYRICVIEW ADDED
 LYRIC ANIMATIONS IMPROVED
 
 
 NEED TO:
 rough up background,
 update annotations to use lyrics- done but needs work
 
 */
 
 
 import SwiftUI
 import AVKit
 import Foundation
 import Combine

struct WelcomeView: View {
    @State private var selectedFile = "fallApart.1"
    @State private var selectedImage = "fallingDownArt"
    @State private var selectedVideo = "fallingVid"
    var videoPlayer: ObservableAVPlayer {
        ObservableAVPlayer(filename: selectedVideo, fileExtension: "mp4")
    }


    var fileNames = ["fallApart.1","general", "fallingDown.1", "twenty"]
    let imageNames = ["BOBart", "juiceArt", "fallingDownArt", "pyscho2Art"]
    let videoNames = ["fallingVid", "introVideo", "trailerVideo"]

    var uniqueAndSortedFileNames: [String] {
        Set(fileNames).sorted()
    }

    var body: some View {
        NavigationView {
            Form {
                Picker("Select JSON File", selection: $selectedFile) {
                    ForEach(uniqueAndSortedFileNames, id: \.self) { fileName in
                        Text(fileName).tag(fileName)
                    }
                }

                Picker("Select Image", selection: $selectedImage) {
                    ForEach(imageNames, id: \.self) { imageName in
                        Text(imageName).tag(imageName)
                    }
                }

                Picker("Select Video", selection: $selectedVideo) {
                    ForEach(videoNames, id: \.self) { videoName in
                        Text(videoName).tag(videoName)
                    }
                }

                NavigationLink("Load", destination: SongView(fileName: selectedFile, imageName: selectedImage, selectedVideo: selectedVideo))
            }
            .navigationBarTitle("Welcome")
        }
    }
}


struct BackgroundView: View {
    var bgColor: Color // Pass the color as a parameter
    var imageName: String // Pass the image name as a parameter

    var body: some View {
        ZStack {
            Image(imageName) // Use the passed image name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 10) // Apply a blur effect
                .overlay(bgColor.opacity(0.5)) // Apply a semi-transparent color overlay
                //.edgesIgnoringSafeArea(.all)
        }
    }
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

struct Annotation: Decodable, Identifiable, Equatable {
    let id: UUID
    let annotation: String
    let lyric: String
    let timestamp: Double
}

 // Function to load song data from JSON
 func loadSongData(fileName: String) -> Song {
     let url = Bundle.main.url(forResource: fileName, withExtension: "json")!

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

struct DotView: View {
    var color: Color
    @State var delay: Double = 0
    @State var scale: CGFloat = 0.4
    @State var isAnimating = false
    @Binding var opacity: Double  // Binding to control the opacity

    var body: some View {
        Circle()
            .fill(isAnimating ? color : color.opacity(0.5))
            .frame(width: 15, height: 15)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(Animation.easeInOut(duration: 0.8).repeatForever().delay(delay), value: isAnimating)
            .onAppear() {
                withAnimation {
                    self.scale = 1
                }
                withAnimation(Animation.easeInOut(duration: 1).repeatForever().delay(delay)) {
                    self.isAnimating = true
                }
            }
    }
}

struct DotRowView: View {
    var textColors: TextColors
    var firstLyricTimestamp: Double
    @State private var opacity: Double = 1.0
    
    var body: some View {
        HStack {
            DotView(color: Color(textColors.textColor1), delay: 0, opacity: $opacity)
            DotView(color: Color(textColors.textColor2), delay: 0.2, opacity: $opacity)
            DotView(color: Color(textColors.textColor3), delay: 0.4, opacity: $opacity)
            DotView(color: Color(textColors.textColor4), delay: 0.6, opacity: $opacity)
            DotView(color: Color(textColors.textColor1), delay: 0.8, opacity: $opacity)
        }
        .onAppear {
            withAnimation(Animation.easeIn(duration: 2)) {
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + firstLyricTimestamp - 2) {
                withAnimation(Animation.easeOut(duration: 2)) {
                    opacity = 0.0
                }}}}}

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
    }}


import SwiftUI
import AVKit

class ObservableAVPlayer: ObservableObject {
    @Published var player: AVPlayer?
    init(filename: String, fileExtension: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) {
            self.player = AVPlayer(url: url)
            // Looping the video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] _ in
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            }
        } else {
            print("Invalid URL for video file")
        }
    }
    func play() {
        self.player?.play()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


struct VideoPlayerView: View {
    @ObservedObject var videoPlayer: ObservableAVPlayer

    var body: some View {
        VStack {
            if let player = videoPlayer.player {
                VideoPlayer(player: player)
                    .onAppear {
                        self.videoPlayer.play()
                    }
            } else {
                Text("Video not available")
            }
        }
    }
}


struct UpperRightVideoView: View {
    @ObservedObject var videoPlayer: ObservableAVPlayer
    var bgColor: Color
    var videoSize: CGFloat
    var imageName: String

    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            if let player = videoPlayer.player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: videoSize, height: videoSize)
                    .onAppear {
                        self.videoPlayer.player?.play() // Correct way to call play
                    }
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: videoSize, height: videoSize)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
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
         //.background(Color(song.bgColor)) // The background color for the whole view
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

    @State private var pulsateScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(isActive ? Color.yellow : Color(textColors.textColor4))
                .frame(width: isActive ? 25 : 18, height: isActive ? 25 : 18)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isActive ? 3 : 1)
                )
                .shadow(color: isActive ? Color.yellow.opacity(0.6) : Color.black.opacity(0.5), radius: isActive ? 3 : 1, x: 0, y: 1)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.yellow : Color.clear, lineWidth: 4)
                        .scaleEffect(pulsateScale)
                        .opacity(Double(2.5 - pulsateScale))
                )
                .scaleEffect(isActive ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: isActive)
                .onAppear {
                    if isActive {
                        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulsateScale = 2.5
                        }
                    }
                }
        }
    }
}


 struct TitleView: View {
     let song: Song
     var imageName: String // Add imageName property
     @Binding var elapsedTime: Float
     
     var body: some View {
         VStack {
             HStack(alignment: .top) { // Align to the top
                 Image(imageName) //  Add imageName property
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
                         .font(.system(size: 22))
                         .multilineTextAlignment(.center)
                         .lineLimit(nil) // Allowing unlimited lines for the description
                         .padding(8)
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
 }
import SwiftUI
import AVKit

struct SongView: View {
    var fileName: String
    var imageName: String
    
    @State private var selectedVideo: String = "default"
    let someThreshold = 3 // Number of lyrics between scroll view reader updates
    @State private var lastScrolledLyricId: UUID? = nil
    @State private var scrollOffset: CGFloat = 0.3  // Closer to 0 positions the lyric closer to the top
    @State private var song: Song
    @State private var currentLyricId: UUID?
    @State private var currentAnnotationId: UUID?
    @State private var currentTime: Double = 0.0
    @State private var timer: Timer? = nil
    @State private var nextAnnotationTime: Double?
    @State private var currentAnnotationStartTime: Double? = nil
    @State private var annotationQueue: [Annotation] = []
    @State private var elapsedTime: Float = 0.0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isTimerRunning = true
    @State private var lyricsChangedSinceLastScroll = 0
    @State private var showLyric = false
    @State private var videoPlayer: ObservableAVPlayer

    var videoSize: CGFloat

    init(fileName: String, imageName: String, selectedVideo: String?) {
        self.fileName = fileName
        self.imageName = imageName
        self.videoSize = UIScreen.main.bounds.width * 0.4
        _song = State(wrappedValue: loadSongData(fileName: fileName))
        
        // Initialize videoPlayer with a default video if selectedVideo is nil
        let videoName = selectedVideo ?? "defaultVideoName" // Replace "defaultVideoName" with an actual default video name
        _videoPlayer = State(initialValue: ObservableAVPlayer(filename: videoName, fileExtension: "mp4"))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView(bgColor: Color(song.bgColor), imageName: imageName) // Add the BackgroundView here

                VStack {
                    ZStack(alignment: .leading) {
                        UpperRightVideoView(videoPlayer: videoPlayer, bgColor: Color(song.bgColor), videoSize: geometry.size.width * 0.4, imageName: imageName)
                            .frame(width: geometry.size.width * 0.4, alignment: .trailing)
                            .position(x: geometry.size.width, y: 0) // Position it at the top right corner

                        TitleView(song: song, imageName: imageName, elapsedTime: $elapsedTime)
                            .frame(width: geometry.size.width * 0.6)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.2) // Make ZStack take the full width

                    playPauseButton()
                    stopButton()

                    lyricsScrollView(geometry: geometry)
                    
                    annotationView(geometry: geometry)

                    AnnotationTimelineView(annotations: song.annotations_with_timestamps, songDuration: song.songDuration, textColors: song.textColors, currentTime: currentTime, currentAnnotationId: currentAnnotationId, song: song)
                        .frame(height: 45)
                        .padding(.bottom)

                    Spacer() // Pushes the content to the top
                }
                .onAppear {
                    setupTimer()
                }
                .onDisappear {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }

    
    private func playPauseButton() -> some View {
        Button(action: {
            self.isTimerRunning.toggle()
            if self.isTimerRunning {
                self.setupTimer()
            } else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }) {
            Text(self.isTimerRunning ? "Pause" : "Play")
                .font(.system(size: 14))
                .padding(10)
                .background(Color(song.textColors.textColor4))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
    }

    private func stopButton() -> some View {
        Button(action: {
            self.timer?.invalidate()
            self.timer = nil
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Stop")
                .font(.system(size: 14))
                .padding(10)
                .background(Color(song.textColors.textColor3))
                .foregroundColor(.white)
                .cornerRadius(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
    }

    private func lyricsScrollView(geometry: GeometryProxy) -> some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(alignment: .center) {
                    ForEach(Array(song.lyrics_with_timestamps.enumerated()), id: \.element.id) { index, lyric in
                        lyricView(lyric, index: index, currentLyricId: currentLyricId)
                    }
                }
                .onChange(of: currentLyricId) { _ in
                    lyricsChangedSinceLastScroll += 1
                    if lyricsChangedSinceLastScroll >= someThreshold {
                        scrollToCurrentLyricIfNeeded(with: scrollView)
                        lyricsChangedSinceLastScroll = 0
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .offset(y: 100)
            .offset(x: 50)
            /*
            .background(
                Color(song.bgColor).overlay(
                    Image(uiImage: UIImage(ciImage: (CIFilter(name: "CIHatchedScreen")?.outputImage ?? CIImage())))
                        .resizable()
                        .opacity(0.8)
                )
            ) */
        }
        .frame(height: geometry.size.height * 0.4)
    }

    private func annotationView(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            if let annotation = song.annotations_with_timestamps.first(where: { $0.id == currentAnnotationId }) {
                Text(annotation.lyric)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding()
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .foregroundColor(Color(song.textColors.textColor1))
                    .shadow(color: Color(song.textColors.textColor1).opacity(0.2), radius: 5, x: 0, y: 0)
                    .shadow(color: Color(song.textColors.textColor1).opacity(0.4), radius: 10, x: 0, y: 0)
                    .shadow(color: Color(song.textColors.textColor1).opacity(0.6), radius: 15, x: 0, y: 0)
                    .opacity(showLyric ? 1 : 0)
                    .offset(x: showLyric ? 0 : -geometry.size.width / 2, y: 0)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.5)) {
                            self.showLyric = true
                        }
                    }

                Text(annotation.annotation)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.07)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(song.textColors.textColor2))
                    .shadow(color: .black, radius: 1)
                    .opacity(currentAnnotationId != nil ? 1 : 0)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1.5), value: currentAnnotationId)
            }
            Spacer()
        }
        .onChange(of: currentAnnotationId) { _ in
            self.showLyric = false
            withAnimation(.easeInOut(duration: 1.0)) {
                self.showLyric = true
            }
        }
        .frame(width: geometry.size.width * 0.5, height: geometry.size.height / 3)
        .offset(x: geometry.size.width / 5, y: -geometry.size.height / 4)
    }

    private func lyricView(_ lyric: Lyric, index: Int, currentLyricId: UUID?) -> some View {
        let isCurrentLyric = lyric.id == currentLyricId

        return Group {
            if currentTime >= song.lyrics_with_timestamps.first?.timestamp ?? 0 {
                HStack(spacing: 0) { // Adding an HStack to wrap the `Text` view
                    Text(lyric.lyric)
                        .id(lyric.id)
                        .padding(.vertical, 1)
                        .padding(.horizontal, 4)
                        .foregroundColor(isCurrentLyric ? Color(song.textColors.textColor1) : Color(song.textColors.textColor2))
                        .font(.system(size: isCurrentLyric ? 17 : 16, weight: isCurrentLyric ? .bold : .medium, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading) // Change this line to remove the full width layout
                        .blur(radius: blurRadiusForIndex(index, currentIndex: song.lyrics_with_timestamps.firstIndex(where: { $0.id == currentLyricId }) ?? 0))
                        .scaleEffect(isCurrentLyric ? 1.1 : 1.0, anchor: .leading)
                        .shadow(color: isCurrentLyric ? Color(song.textColors.textColor1) : Color.clear, radius: isCurrentLyric ? 10 : 0)
                        .brightness(isCurrentLyric ? 0.2 : 0)
                        .animation(.easeInOut(duration: 0.5), value: isCurrentLyric)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 2.0), value: lyric.id) // Change the duration of the transition
                    Spacer() // Adding a spacer to take up the remaining width on the right side
                }
            } else {
                if currentTime < song.lyrics_with_timestamps.first?.timestamp ?? 0 && index == 0 {
                    let firstLyricTimestamp = song.lyrics_with_timestamps.first?.timestamp ?? 0
                    DotRowView(textColors: song.textColors, firstLyricTimestamp: firstLyricTimestamp)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading) // Change this line to remove the full width layout
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 2.0), value: lyric.id)
                } else {
                    EmptyView()
                }
            }
        }
    }


         private func distanceToCurrentLyric() -> Int {
     guard let currentLyricId = currentLyricId,
           let currentIndex = song.lyrics_with_timestamps.firstIndex(where: { $0.id == currentLyricId }) else {
         return 0
     }

     let targetIndex = song.lyrics_with_timestamps.firstIndex(where: { $0.timestamp <= currentTime }) ?? 0
     return abs(currentIndex - targetIndex)
 }
         
        private func scrollToCurrentLyricIfNeeded(with scrollView: ScrollViewProxy) {
     guard let currentLyricId = currentLyricId else {
         return
     }
     withAnimation(.easeInOut(duration: 0.3)) {
         scrollView.scrollTo(currentLyricId, anchor: UnitPoint(x: 0.5, y: scrollOffset))
     } completion: {
         lastScrolledLyricId = currentLyricId
     }
 }
         

         private func getLyricPosition(currentTime: Double, previousLyricTime: Double, nextLyricTime: Double) -> Double {
                 let position = (currentTime - previousLyricTime) / (nextLyricTime - previousLyricTime)
                 return position
             }

         private func blurRadiusForIndex(_ index: Int, currentIndex: Int) -> CGFloat {
             let distance = abs(currentIndex - index)
             switch distance {
             case 0...2:
                 return 0 // No blur for current lyric and lyrics close to it
             default:
                 return CGFloat(distance - 3) * 1.5 // Increasing blur with distance
             }
         }
         
         private func updateLyrics() {
     // Find the nearest lyric
     let nearestLyric = song.lyrics_with_timestamps.min(by: { abs($0.timestamp - currentTime) < abs($1.timestamp - currentTime) })

     if let lyric = nearestLyric, lyric.timestamp <= currentTime {
         if currentLyricId != lyric.id {
             currentLyricId = lyric.id
             print("Current lyric updated to: \(lyric.lyric)")
         }
     }
 }
         
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
         private func setupTimer() {
                 self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                     self.currentTime += 0.1
                     self.updateLyrics()
                     self.updateAnnotations()
                     
                     // Check if the song has ended
                     if self.currentTime >= Double(self.song.songDuration) / 1000.0 {
                         self.timer?.invalidate()
                         self.timer = nil
                         self.presentationMode.wrappedValue.dismiss() // Navigate back to the Welcome screen
                     }
                 }
             }

         }


 @main
 struct _2_01App: App {
     var body: some Scene {
         WindowGroup {
             WelcomeView()
         }
     }
 }

/*
struct BackgroundImageView: View {
    var body: some View {
        Image("imageName") // Replace with your actual background image name
            .resizable()
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
    }
}

@main
struct _2_01App: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                BackgroundImageView()
                WelcomeView().opacity(0.8)
            }
        }
    }
}
*/
