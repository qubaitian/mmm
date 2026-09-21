#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_target=${1:-web}
build_options=(--variant debug --archive)

if [ "$#" -gt 1 ]; then
  echo "Usage: ./build.sh [web|desktop]" >&2
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
  *) echo "Usage: ./build.sh [web|desktop]" >&2; exit 1 ;;
esac

shopt -s nullglob
packages="${DEFOLD_APP:-/Applications/Defold.app}/Contents/Resources/packages"
java_tools=("$packages"/jdk-*/bin/java)
bob_tools=("$packages"/defold-*.jar)
if [ "${#java_tools[@]}" -ne 1 ] || [ "${#bob_tools[@]}" -ne 1 ]; then
  echo "Cannot find Defold tools. Install Defold in /Applications or set DEFOLD_APP." >&2
  exit 1
fi

exec "${java_tools[0]}" \
  -Dcom.google.protobuf.use_unsafe_pre22_gencode=true \
  --enable-native-access=ALL-UNNAMED \
  -cp "${bob_tools[0]}" com.dynamo.bob.Bob \
  --root "$project_root/defold" \
  --platform "$build_platform" \
  "${build_options[@]}" \
  --bundle-output "$project_root/dist/$build_target" \
  resolve build bundle
