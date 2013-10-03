class GSAPI


  # Helper functions
  formatPlaylistInfo = (playlist, playlistID) ->
    # The response from the Grooveshark API's `getPlaylist` function doesn't include the playlist id, 
    # so we have to pass it in manually. In addition to that the API's `getUserPlaylists` method returns 
    # playlists with less information than `getPlaylist`. Below is an attempt to make the two formats 
    # more consistent, but ultimately there's missing and mismatching information and it's not possible 
    # (unless you want to loop through all of a user's playlists and call `getPlaylist` for each one, 
    # which is a lot of calls).
    if (playlistID)
      return {
        id: playlistID
        name: playlist.PlaylistName
        modified: playlist.TSModified
        description: playlist.PlaylistDescription
        userID: playlist.UserID
        coverArt: 'http://images.gs-cdn.net/static/playlists/200_' + body.CoverArtFilename
      }
    else
      return {
        id: playlist.PlaylistID
        name: playlist.PlaylistName
        added: playlist.TSAdded
      }

  formatSongs = (songs) ->
    for song in songs
      song =
        id: song.SongID
        name: song.SongName
        artist:
          id: song.ArtistID
          name: song.ArtistName
        album:
          id: song.AlbumID
          name: song.AlbumName
          art: if song.CoverArtFilename then 'http://images.gs-cdn.net/static/albums/142_' + song.CoverArtFilename else null
        sort: if song.Sort then song.Sort else null

  formatUserInfo = (body) ->
    return {
      userID: body.UserID
      firstName: body.FName
      lastName: body.LName
      isPremium: body.IsPremium
      isPlus: body.IsPlus
      isAnywhere: body.IsAnywhere
    }

  formatArtistInfo = (body) ->
    return {
      id: body.ArtistID
      name: body.ArtistName
    }

  formatAlbumInfo = (body) ->
    return {
      id: body.AlbumID
      name: body.AlbumName
      art: if body.CoverArtFilename then 'http://images.gs-cdn.net/static/albums/142_' + body.CoverArtFilename else null
      artist:
        id: body.ArtistID
        name: body.ArtistName
    }


  # Core Methods
  getPlaylist: (playlistID, cb) ->
    @request('getPlaylist', {playlistID: playlistID}, (err, status, body) =>
      return cb(err) if err
      info = formatPlaylistInfo(body, playlistID)
      songs = formatSongs(body.Songs)
      cb(info, songs)
    )

  getUserInfo: (userID, cb) ->
    if !cb
      # if there is no callback, that means no userID was passed in. In this case,
      # get info of the currently authenticated user.
      cb = userID
      @request('getUserInfo', {}, (err, status, body) =>
        return cb(err) if err
        info = formatUserInfo(body)
        cb(info)
      )
    else
      # if the userID is not a number, then a username is being passed in. Call `getUserIDFromUsername`
      # to convert the username to a userID. Then re-call the `getUserInfo` function.
      if (isNaN(userID))
        @request('getUserIDFromUsername', {username: userID}, (err, status, body) =>
          return cb(err) if err
          @getUserInfo(body.UserID, cb)
        )
      else
        @request('getUserInfoFromUserID', {userID: userID}, (err, status, body) =>
          return cb(err) if err
          info = formatUserInfo(body)
          cb(info)
        )

  getUserLibrary: (cb) ->
    @request('getUserLibrarySongs', {}, (err, status, body) =>
      return cb(err) if err
      songs = formatSongs(body.songs)
      cb(songs)
    )

  getUserCollection: (cb) ->
    @getUserLibrary(cb)

  getUserFavorites: (cb) ->
    @request('getUserFavoriteSongs', {}, (err, status, body) =>
      return cb(err) if err
      songs = @formatSongs(body.songs)
      cb(songs)
    )

  getUserPlaylists: (userID, cb) ->
    # if there is no callback, that means no userID was passed in. In this case,
    # get playlists for the currently authenticated user.
    if !cb
      cb = userID
      @request('getUserPlaylists', {}, (err, status, body) =>
        return cb(err) if err
        playlists = (formatPlaylistInfo(playlist) for playlist in body.playlists)
        cb(playlists)
      )
    else
      # if the userID is not a number, then a username is being passed in. Call `getUserIDFromUsername`
      # to convert the username to a userID. Then re-call the `getUserPlaylists` function.
      if (isNaN(userID))
        @request('getUserIDFromUsername', {username: userID}, (err, status, body) =>
          return cb(err) if err
          @getUserPlaylists(body.UserID, cb)
        )
      else
        @request('getUserPlaylistsByUserID', {userID: userID}, (err, status, body) =>
          return cb(err) if err
          playlists = (formatPlaylistInfo(playlist) for playlist in body.playlists)
          cb(playlists)
        )


  # Search Methods
  searchSongs: (song, country, cb) ->
    if !cb
      cb = country
      country = 'USA'
    @request('getSongSearchResults', {query: song, country: country}, (err, status, body) =>
      return cb(err) if err
      songs = formatSongs(body.songs)
      cb(songs)
    )

  searchPlaylists: (playlistName, cb) ->
    @request('getPlaylistSearchResults', {query: playlistName}, (err, status, body) =>
      return cb(err) if err
      playlists = (formatPlaylistInfo(playlist) for playlist in body.playlists)
      cb(playlists)
    )

  searchArtists: (artistName, cb) ->
    @request('getArtistSearchResults', {query: artistName}, (err, status, body) =>
      return cb(err) if err
      artists = (formatArtistInfo(artist) for artist in body.artists)
      cb(artists)
    )

  searchAlbums: (albumName, cb) ->
    @request('getAlbumSearchResults', {query: albumName}, (err, status, body) =>
      return cb(err) if err
      albums = (formatAlbumInfo(album) for album in body.albums)
      cb(albums)
    )


module.exports = GSAPI
