//
//  MusicView.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI
import MusicKit
import Combine

struct MusicView: View {
        
    @State private var authorizationStatus: MusicAuthorization.Status = .notDetermined
    @State private var isPresentingPlaylistPicker = false
    @State private var selectedPlaylist: Playlist?
    @State private var isPlaying: Bool = false
    @State private var currentEntryTitle: String = ""
    @State private var currentArtworkURL: URL?
    @State private var shuffleMode: ApplicationMusicPlayer.ShuffleMode = .off
    @State private var repeatMode: ApplicationMusicPlayer.RepeatMode = .none
    @State private var errorMessage: String?

    private let player = ApplicationMusicPlayer.shared
    
    private let musicColor: Color = Color(r: 255, g: 4, b: 54)
    
#if targetEnvironment(macCatalyst)
    
    private let baseSize: CGFloat = 300
    
    private let basePadding: CGFloat = 18
    
    private func sizeMultiplier(for width: CGFloat) -> CGFloat {
       
        
         if width < 380 {
             return 0.6
         }
        
        if width < 400 {
            return 0.75
        }
        
        if width < 410 {
            return 1
        }
        
        if width < 500 {
            return 1.8
        }
        
        return 2
    }

#endif // targetEnvironment(macCatalyst)

#if os(iOS)

    private let baseSize: CGFloat = 300
    
    private let basePadding: CGFloat = 18
    
    private func sizeMultiplier(for width: CGFloat) -> CGFloat {
       
        
         if width < 380 {
             return 0.6
         }
        
        if width < 400 {
            return 0.75
        }
        
        if width < 440 {
            return 1
        }
        
        if width < 500 {
            return 1.1
        }
        
        return 2
    }
    
#endif

    
    private func debugWidth(for width: CGFloat) -> CGFloat {
        return width
    }


    var body: some View {
        GeometryReader { proxy in
            let scaledBaseSize = baseSize * sizeMultiplier(for: proxy.size.width)
            let scaledPadding = basePadding * sizeMultiplier(for: proxy.size.width)
//            var debug: String = String(format: "Debug width %.2f", debugWidth(for: proxy.size.width))
            NavigationStack {
                VStack(spacing: 20) {
                    Group {
                        if let playlist = selectedPlaylist {
                            VStack(spacing: 8) {
                                if let url = currentArtworkURL {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(
                                                    width: scaledBaseSize,
                                                    height: scaledBaseSize
                                                )
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(
                                                    width: scaledBaseSize,
                                                    height: scaledBaseSize
                                                )
                                                .glassEffect(
                                                    .regular.interactive(),
                                                    in: .rect(cornerRadius: 28.0)
                                                )
                                                .clipShape(
                                                    RoundedRectangle(
                                                        cornerRadius: 28
                                                    )
                                                )
                                        case .failure:
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(
                                                    width: scaledBaseSize,
                                                    height: scaledBaseSize
                                                )
                                                .overlay(
                                                    Image(systemName: "music.note")
                                                        .font(.largeTitle)
                                                        .foregroundStyle(.secondary)
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                         
                                Text(playlist.name)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(8)
                                if !currentEntryTitle.isEmpty {
                                    Text(currentEntryTitle)
                                        .font(.subheadline)
                                        .padding(8)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Image(systemName: "music.note")
                                .font(
                                    .system(
                                        size: 140,
                                        weight: .regular,
                                        design: .default
                                    )
                                )
                                .frame(width: scaledBaseSize, height: scaledBaseSize)
                                .glassEffect(
                                    .clear.tint(musicColor).interactive(),
                                    in: .rect(cornerRadius: 28.0)
                                )
                                .padding(.top, 32)
//                            Text(debug)
//                                .font(Font.default.bold())
//                                .foregroundStyle(.primary)
                            Text("No playlist selected")
                                .foregroundColor(.secondary)
                                .padding(6)
                        }
                    }

                    HStack(spacing: 24) {
                        Button {
                            Task { await skipBackward() }
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                        }
                        .disabled(selectedPlaylist == nil)
                        .controlSize(.large)


                        Button {
                            Task { await togglePlayPause() }
                        } label: {
                            Image(
                                systemName: isPlaying ? "pause.fill" : "play.fill"
                            )
                            .font(.title)
                        }
                        .disabled(selectedPlaylist == nil)
                        .controlSize(.large)


                        Button {
                            Task { await skipForward() }
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                        }
                        .disabled(selectedPlaylist == nil)
                        .controlSize(.large)
                    }
                    .padding(scaledPadding)
                    .glassEffect(.regular.interactive())

                    HStack(spacing: 24) {
                        Button {
                            Task { await toggleShuffle() }
                        } label: {
                            Image(systemName: "shuffle")
                                .symbolRenderingMode(.multicolor)
                                .font(.title3)
                                .foregroundColor(
                                    shuffleMode == .off ? .primary : musicColor
                                )
                        }
                        .buttonStyle(.glass)
                        .controlSize(.regular)
                        .disabled(selectedPlaylist == nil)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())

                        Button {
                            Task { await cycleRepeatMode() }
                        } label: {
                            Group {
                                switch repeatMode {
                                case .none:
                                    Image(systemName: "repeat")
                                case .all:
                                    Image(systemName: "repeat")
                                        .foregroundStyle(musicColor)
                                case .one:
                                    Image(systemName: "repeat.1")
                                        .foregroundStyle(musicColor)
                                @unknown default:
                                    Image(systemName: "repeat")
                                }
                            }
                            .symbolRenderingMode(.multicolor)
                            .font(.title3)
                            .foregroundColor(
                                repeatMode == .none ? .primary : Color.blue
                            )
                        }
                        .buttonStyle(.glass)
                        .controlSize(.regular)

                        .disabled(selectedPlaylist == nil)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button {
                        Task { await presentOrRequestMusicAccess() }
                    } label: {
                        Label(
                            authorizationStatus == .authorized ? "Choose Playlist" : "Connect Apple Music",
                            systemImage: "music.note"
                        )
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    .sheet(isPresented: $isPresentingPlaylistPicker) {
                        PlaylistPickerView { playlist in
                            isPresentingPlaylistPicker = false
                            Task { await loadAndPlay(playlist: playlist) }
                        }
                    }
                }
                .navigationTitle("Music")
                .toolbarBackground(Color(r:255, g:4, b:54), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .task { await refreshAuthorization() }
                .task {
                    // Lightweight polling to reflect playback changes
                    for await _ in Timer
                        .publish(every: 1.0, on: .main, in: .common)
                        .autoconnect().values {
                        await updatePlaybackState()
                        await updateNowPlayingInfo()
                        await updatePlaybackModes()
                    }
                }
            }
        }
    }
}

// MARK: - Actions
private extension MusicView {
    func presentOrRequestMusicAccess() async {
        switch authorizationStatus {
        case .authorized:
            isPresentingPlaylistPicker = true
        case .notDetermined, .restricted, .denied:
            let status = await MusicAuthorization.request()
            authorizationStatus = status
            if status == .authorized {
                isPresentingPlaylistPicker = true
            } else {
                errorMessage = "Apple Music access is required to choose a playlist."
            }
        @unknown default:
            errorMessage = "Unknown authorization status."
        }
    }

    func refreshAuthorization() async {
        authorizationStatus = MusicAuthorization.currentStatus
        await updatePlaybackState()
        await updateNowPlayingInfo()
        await updatePlaybackModes()
    }

    func loadAndPlay(playlist: Playlist) async {
        do {
            // Fetch full playlist with tracks
            let detailed = try await playlist.with([.tracks])
            guard let tracks = detailed.tracks, !tracks.isEmpty else {
                errorMessage = "Selected playlist has no tracks."
                return
            }
            selectedPlaylist = detailed

            // Build and set a queue for the application music player
            let queue = ApplicationMusicPlayer.Queue(for: [detailed])
            try await player.queue = queue

            try await player.play()
            await updatePlaybackState()
            await updateNowPlayingInfo()
            await updatePlaybackModes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func togglePlayPause() async {
        do {
            switch player.state.playbackStatus {
            case .playing:
                try await player.pause()
            default:
                try await player.play()
            }
            await updatePlaybackState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func skipForward() async {
        do {
            try await player.skipToNextEntry()
            await updateNowPlayingInfo()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func skipBackward() async {
        do {
            try await player.skipToPreviousEntry()
            await updateNowPlayingInfo()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updatePlaybackState() async {
        await MainActor.run {
            isPlaying = player.state.playbackStatus == .playing
        }
    }

    func updateNowPlayingInfo() async {
        let entry = player.queue.currentEntry
        let title = entry?.title ?? ""
        var artworkURL: URL? = nil
        if let artwork = entry?.artwork {
            artworkURL = artwork.url(width: 320, height: 320)
        }
        await MainActor.run {
            currentEntryTitle = title
            currentArtworkURL = artworkURL
        }
    }

    func toggleShuffle() async {
        do {
            let current = player.state.shuffleMode ?? .off
            let newMode: ApplicationMusicPlayer.ShuffleMode = (
                current == .off
            ) ? .songs : .off
            player.state.shuffleMode = newMode
            await updatePlaybackModes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cycleRepeatMode() async {
        do {
            let current = player.state.repeatMode ?? .none
            let next: ApplicationMusicPlayer.RepeatMode
            switch current {
            case .none: next = .all
            case .all: next = .one
            case .one: next = .none
            @unknown default: next = .none
            }
            player.state.repeatMode = next
            await updatePlaybackModes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updatePlaybackModes() async {
        await MainActor.run {
            shuffleMode = player.state.shuffleMode ?? .off
            repeatMode = player.state.repeatMode ?? .none
        }
    }
}

// MARK: - Playlist Picker
private struct PlaylistPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var playlists: MusicItemCollection<Playlist> = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    let onSelect: (Playlist) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading Playlists…")
                } else if let errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if playlists.isEmpty {
                    Text("No playlists found.")
                        .foregroundStyle(.secondary)
                } else {
                    List(playlists, id: \.id) { playlist in
                        Button {
                            onSelect(playlist)
                        } label: {
                            HStack(spacing: 12) {
                                ArtworkImage(playlist.artwork, width: 44)
                                VStack(alignment: .leading) {
                                    Text(playlist.name)
                                    if let curatorName = playlist.curatorName, !curatorName.isEmpty {
                                        Text(curatorName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await loadPlaylists() }
        }
    }

    func loadPlaylists() async {
        do {
            isLoading = true
            errorMessage = nil
            // Fetch user's library playlists
            let request = MusicLibraryRequest<Playlist>()
            let response = try await request.response()
            await MainActor.run {
                playlists = response.items
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

private struct ArtworkImage: View {
    let artwork: Artwork?
    let width: CGFloat

    init(_ artwork: Artwork?, width: CGFloat) {
        self.artwork = artwork
        self.width = width
    }

    var body: some View {
        Group {
            if let artwork, let url = artwork.url(
                width: Int(width * 2),
                height: Int(width * 2)
            ) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: width, height: width)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: width)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: width)
            .overlay(
                Image(systemName: "music.note").foregroundStyle(.secondary)
            )
    }
}

#Preview{
    ContentView()
}

#Preview{
    MusicView()
}

