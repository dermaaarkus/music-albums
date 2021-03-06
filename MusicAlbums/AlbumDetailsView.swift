//
//  AlbumDetailsView.swift
//  MusicAlbums
//
//  Created by Markus Faßbender on 05.02.20.
//

import SwiftUI
import Models
import NetworkService

struct AlbumDetailsView: View {
    
    @State var album: Album
    
    @State private var cancelToken: CancelToken?
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                ZStack {
                    Rectangle()
                        .fill(Color(Stylesheet.Color.imageBackground))

                    if album.image != nil {
                        Image(uiImage: album.image!)
                            .resizable()
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                
                VStack(alignment: .leading) {
                    AlbumDetailsInformationView(album: album)
                    AlbumDetailsTracksView(tracks: album.tracks)
                }
                .padding([.leading, .trailing, .bottom])
            }
        }
        .onAppear {
            self.loadDetails()
        }
        .onDisappear() {
            self.cancelToken?.cancel()
        }
    }
}

extension AlbumDetailsView {
    private func loadDetails() {
        cancelToken?.cancel()
        
        let resource = Album.allDetails(for: album)
        let token = CancelToken()
        cancelToken = token
        
        Webservice.shared.load(resource: resource, token: token) {
            switch $0 {
            case .success(let album):
                self.album = album
            case .failure(let error):
                print(error) // just don't update interface for now
            }
        }
    }
}
