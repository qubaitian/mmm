#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_target=${1:-web}
build_options=(--variant debug --archive)
usage="Usage: ./build.sh [web|desktop|android]"

if [ "$#" -gt 1 ]; then
  echo "$usage" >&2
  exit 1
fi

case "$build_target" in
  web)
    build_platform=wasm-web
    build_options+=(--architectures wasm-web)
    ;;
  desktop)
    case "$(uname -m)" in
      arm64) build_platform=arm64-macos ;;
      x86_64) build_platform=x86_64-macos ;;
      *) echo "Desktop builds require macOS on Apple Silicon or Intel." >&2; exit 1 ;;
    esac
    ;;
  android)
    build_platform=armv7-android
    build_options+=(--architectures armv7-android,arm64-android --bundle-format apk)
    ;;
  *) echo "$usage" >&2; exit 1 ;;
esac

shopt -s nullglob
packages="${DEFOLD_APP:-/Applications/Defold.app}/Contents/Resources/packages"
java_tools=("$packages"/jdk-*/bin/java)
bob_tools=("$packages"/defold-*.jar)
if [ "${#java_tools[@]}" -ne 1 ] || [ "${#bob_tools[@]}" -ne 1 ]; then
  echo "Cannot find Defold tools. Install Defold in /Applications or set DEFOLD_APP." >&2
  exit 1
fi

version=""
if [ "${SKIP_VERSION_BUMP:-}" = 1 ]; then
  version=$(python3 -c "import re, pathlib; t=pathlib.Path('$project_root/defold/game.project').read_text(); print(re.search(r'(?m)^version\\s*=\\s*(\\S+)', t).group(1))")
else
  version=$(python3 "$project_root/bump_version.py" "$project_root/defold/game.project")
fi
echo "Version $version"

"${java_tools[0]}" \
  -Dcom.google.protobuf.use_unsafe_pre22_gencode=true \
  --enable-native-access=ALL-UNNAMED \
  -cp "${bob_tools[0]}" com.dynamo.bob.Bob \
  --root "$project_root/defold" \
  --platform "$build_platform" \
  "${build_options[@]}" \
  --bundle-output "$project_root/dist/$build_target" \
  resolve build bundle

if [ "$build_target" = android ]; then
  mkdir -p "$project_root/dist/web/mmm"
  apk=""
  for candidate in "$project_root/dist/android"/*.apk "$project_root/dist/android"/*/*.apk; do
    if [ -f "$candidate" ]; then
      apk=$candidate
      break
    fi
  done
  if [ -z "$apk" ]; then
    echo "Android bundle did not create an APK." >&2
    exit 1
  fi
  cp "$apk" "$project_root/dist/web/mmm/mmm.apk"
  cp "$apk" "$project_root/dist/web/mmm/mmm-$version.apk"
  echo "APK version $version"
  echo "Download http://192.168.110.229:8080/mmm-$version.apk"
fi
