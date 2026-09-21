# mmm - Mobile MMO

## Server

```bash
npm --prefix server install
npm --prefix server run build
npm --prefix server start
```

The server listens on `0.0.0.0:2567`.  
Web and Android clients connect to `ws://192.168.110.229:2567`.  

## Web

Build and serve the web app in another terminal:

```bash
./build.sh web
python3 -m http.server 8080 --bind 0.0.0.0 --directory dist/web/mmm
```

Open the [web app](http://192.168.110.229:8080/).  

## Android

```bash
./build.sh android
```

The APK also copies to `dist/web/mmm/mmm-x.y.z.apk`.  
Each Android build bumps the last number, like `1.0.0` to `1.0.1`.  
The command prints the download URL.  

## macOS Desktop

```bash
./build.sh desktop
open dist/desktop/mmm.app
```

## Art

Tiles and characters come from [Kenney Scribble Dungeons](https://kenney.nl/assets/scribble-dungeons).  
Input icons come from [Kenney Input Prompts](https://kenney.nl/assets/input-prompts).  
License: [CC0](https://creativecommons.org/publicdomain/zero/1.0/).  
