# mmm - Mobile MMO

## Server

```bash
npm --prefix server install
npm --prefix server run build
npm --prefix server start
```

The server uses port `2567`.  

## Web

Build and serve the web app in another terminal:

```bash
./build.sh web
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist/web/mmm
```

Open the [web app](http://127.0.0.1:8080/).  

## macOS Desktop

```bash
./build.sh desktop
open dist/desktop/mmm.app
```

## Art

Tiles and characters come from [Kenney Scribble Dungeons](https://kenney.nl/assets/scribble-dungeons).  
License: [CC0](https://creativecommons.org/publicdomain/zero/1.0/).  
