[![build status](https://secure.travis-ci.org/theycallmeswift/grooveshark.png)](http://travis-ci.org/theycallmeswift/grooveshark)

# Grooveshark

This is a package for interacting with the [Grooveshark V3 API](http://developers.grooveshark.com/docs/public_api/v3/) using node.js.

## Installation

    npm install grooveshark

## Usage

    var gs = require('grooveshark')
      , client = new gs('your_api_key', 'your_api_secret');

    client.authenticate('your_grooveshark_username', 'you_grooveshark_password', function(err) {
      client.request('someMethod', {param1: 'foobar', param2: 1234}, function(err, status, body) {
        if(err) {
          throw err
        }

        console.log(body);
      });
    })

## Building

Install [CoffeeScript](http://coffeescript.org/).

Then run:

    coffee --compile --output lib/ src/

## API Methods

While all API methods mentioned in the [Grooveshark V3 API](http://developers.grooveshark.com/docs/public_api/v3/) can be called via the `client.request` method, a layer of abstraction has been added to make querying the API and parsing results a little easier. The functions added and the results they return include the following:

Methods include:

- `getPlaylist`
- `getUserInfo`
- `getUserLibrary`
- `getUserCollection` (alias for `getUserLibrary`)
- `getUserFavorites`
- `getUserPlaylists`
- `searchSongs`
- `searchPlaylists`
- `searchArtists`
- `searchAlbums`

#### getPlaylist

Grabs info and songs from any playlist.

- **Required Params**: `int:playlistID`, `fun:callback(info, songs)`
- **Optional Params**: n/a
- **Authentication Req**: No

Example request:

```js
client.getPlaylist(88862109, function(info, songs) {
  console.log(info);
  //=>  {
  //=>    name: 'Bonoboish',
  //=>    modified: 1379986260,
  //=>    description: '',
  //=>    userID: 3110324,
  //=>    coverArt: 'http://images.gs-cdn.net/static/playlists/200_189851-268433-354171-6939573.jpg'
  //=>  }

  console.log(songs);
  //=>  [{ 
  //=>    id: 660650,
  //=>    name: 'Orbit Brazil',
  //=>    artist: { 
  //=>      id: 51859, 
  //=>      name: 'Flying Lotus' 
  //=>    },
  //=>    album: { 
  //=>      id: 284895,
  //=>      name: '1983',
  //=>      art: 'http://images.gs-cdn.net/static/albums/142_284895.jpg' 
  //=>    },
  //=>    sort: 27
  //=>   }, ... many more songs ... ] 
```

#### getUserInfo

Gets information about a user from either a userID or a username. If no userID or username is provided, gets information about the currently logged in user.

- **Required Params**: `fun:callback(userInfo)`
- **Optional Params**: `str:username` or `int:userID`
- **Authentication Req**: No if `username` or `userID` provided. Else Yes

Example requests:

```js
client.getUserInfo("L1fescape", function(userInfo) {
  console.log(userInfo);
  //=>  { 
  //=>    userID: 3110324,
  //=>    firstName: 'Andrew Kennedy',
  //=>    lastName: '',
  //=>    isPremium: true,
  //=>    isPlus: false,
  //=>    isAnywhere: true 
  //=>  }
});

client.getUserInfo(3110324, function(userInfo) {
  console.log(userInfo);
  //=>  { 
  //=>    userID: 3110324,
  //=>    firstName: 'Andrew Kennedy',
  //=>    lastName: '',
  //=>    isPremium: true,
  //=>    isPlus: false,
  //=>    isAnywhere: true 
  //=>  }
});

client.authenticate('gs_username', 'gs_password', function(err) {
  client.getUserInfo(function(userInfo) {
    console.log(userInfo);
    //=>  { 
    //=>    userID: 3110324,
    //=>    firstName: 'Andrew Kennedy',
    //=>    lastName: '',
    //=>    isPremium: true,
    //=>    isPlus: false,
    //=>    isAnywhere: true 
    //=>  }
  });
});
```

#### getUserLibrary

Gets all songs in the library of an authenticated user.

- **Required Params**: `fun:callback(songs)`
- **Optional Params**: n/a
- **Authentication Req**: Yes

Example requests:

```js
client.authenticate('gs_username', 'gs_password', function(err) {
  client.getUserLibrary(function(songs) {
    console.log(songs);
    //=>  [{ 
    //=>    id: 39496255,
    //=>    name: 'All I Know',
    //=>    artist: { 
    //=>      id: 1187703, 
    //=>      name: 'Washed Out' 
    //=>    },
    //=>    album: { 
    //=>      id: 9147860, 
    //=>      name: 'BIRP! August 2013', 
    //=>      art: null 
    //=>    },
    //=>    sort: null
    //=>   }, ... many more songs ... ] 
  });
});
```

#### getUserCollection

Alias for `getUserLibrary`. Accepts same arguments, returns same results.


#### getUserFavorites

Gets all of an authenticated user's favorites songs.

- **Required Params**: `fun:callback(songs)`
- **Optional Params**: n/a
- **Authentication Req**: Yes

Example requests:

```js
client.authenticate('gs_username', 'gs_password', function(err) {
  client.getUserFavorites(function(songs) {
    console.log(songs);
    //=>  [{ 
    //=>    id: 21680619,
    //=>    name: 'Recurring',
    //=>    artist: { 
    //=>      id: 20982, 
    //=>      name: 'Bonobo' 
    //=>    },
    //=>    album: { 
    //=>      id: 191190,
    //=>      name: 'Days To Come',
    //=>      art: 'http://images.gs-cdn.net/static/albums/142_191190.jpg' 
    //=>    },
    //=>    sort: null
    //=>   }, ... many more songs ... ] 
  });
});
```

#### getUserPlaylists

Gets all of a user's playlists from either a userID or a username. If no userID or username is provided, gets all of the currently logged in user's playlists.

- **Required Params**: `fun:callback(playlists)`
- **Optional Params**: `str:username` or `int:userID`
- **Authentication Req**: No if a `username` or `userID` provided. Else Yes

Example requests:

```js
client.getUserPlaylists("L1fescape", function(playlists) {
  console.log(playlists);
  //=>  [{ 
  //=>    id: 88862109, 
  //=>    name: 'Bonoboish', 
  //=>    added: '2013-07-26 10:40:09'
  //=>   }, ... many more playlists ... ] 
});

client.getUserPlaylists(3110324, function(playlists) {
  console.log(playlists);
  //=>  [{ 
  //=>    id: 88862109, 
  //=>    name: 'Bonoboish', 
  //=>    added: '2013-07-26 10:40:09'
  //=>   }, ... many more playlists ... ] 
});

client.authenticate('gs_username', 'gs_password', function(err) {
  client.getUserPlaylists(function(playlists) {
    console.log(playlists);
    //=>  [{ 
    //=>    id: 88862109, 
    //=>    name: 'Bonoboish', 
    //=>    added: '2013-07-26 10:40:09'
    //=>   }, ... many more playlists ... ] 
  });
});
```

#### searchSongs

Search songs based on name.

- **Required Params**: `str:songName`, `fun:callback(songs)`
- **Optional Params**: `str:country`
- **Authentication Req**: No

Example requests:

```js
client.searchSongs("Smoke on the water", function(songs) {
  console.log(songs);
  //=>  [{ 
  //=>    id: 33682674,
  //=>    name: 'Smoke on the Water',
  //=>    artist: { 
  //=>      id: 3465, 
  //=>      name: 'Deep Purple' 
  //=>    },
  //=>    album: { 
  //=>      id: 180295,
  //=>      name: 'Very Best of Deep Purple',
  //=>      art: 'http://images.gs-cdn.net/static/albums/142_180295.jpg' 
  //=>    },
  //=>    sort: null
  //=>   }, ... many more songs ... ] 
});
```

#### searchPlaylists

Search playlists based on name.

- **Required Params**: `str:playlistName`, `fun:callback(playlists)`
- **Optional Params**: n/a
- **Authentication Req**: No

Example requests:

```js
client.searchPlaylists("Chillout", function(playlists) {
  console.log(playlists);
  //=>  [{ 
  //=>    id: 33166293, 
  //=>    name: 'ChillOut  ', 
  //=>    added: '0'
  //=>   }, ... many more playlists ... ] 
});
```

#### searchArtists

Search artists based on name.

- **Required Params**: `str:artistName`, `fun:callback(artists)`
- **Optional Params**: n/a
- **Authentication Req**: No

Example requests:

```js
client.searchPlaylists("Bonobo", function(artists) {
  console.log(artists);
  //=>  [{ 
  //=>    id: 20982, 
  //=>    name: 'Bonobo' 
  //=>   }, ... many more artists ... ] 
});
```

#### searchAlbums

Search albums based on name.

- **Required Params**: `str:albumName`, `fun:callback(albums)`
- **Optional Params**: n/a
- **Authentication Req**: No

Example requests:

```js
client.searchPlaylists("2112", function(albums) {
  console.log(albums);
  //=>  [{ 
  //=>    id: 1103744,
  //=>    name: '2112',
  //=>    art: 'http://images.gs-cdn.net/static/albums/142_1103744.jpg',
  //=>    artist: { 
  //=>      id: 402377, 
  //=>      name: 'Rush' 
  //=>    }
  //=>   }, ... many more albums ... ] 
});
```
