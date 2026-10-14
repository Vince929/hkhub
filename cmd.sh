#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

usage() {
  cat <<'EOF'
Usage: ./cmd.sh [command] [Flutter args]

  init                 Create .env, install dependencies and generate localization code
  run (default)        Run on a selected device with the configured API environments
  android              Run with Android emulator API address (10.0.2.2)
  usb [device-id]      Reverse API port with adb and run on an Android USB device
  ios                  Run on an iOS simulator (pass -d <simulator-id>)
  web                  Run Chrome on localhost:8080 (matches backend CORS)
  devices              List available Flutter devices
  l10n                 Generate localization code from ARB files
  icons                Regenerate every app icon and the splash logo from the sail mark
  apk                  Build a release APK (configure productionApiBaseUrl in Dart first)
  appbundle            Build a release Android App Bundle
  ipa                  Build a signed release IPA
  test [args]          Run Flutter tests
  lint                 Run flutter analyze
  format               Format lib/ and test/
  clean                Remove Flutter build output
  help                 Show this help

Edit API URLs and initial environment in lib/app/config/app_config.dart.
Hot reload refreshes Dart configuration and API clients in development.
Switch configured environments at runtime in Settings; the choice is saved on the device.
Unconfigured test/production environments are disabled. Production requires HTTPS.
Real devices: set localApiBaseUrl to your computer's reachable address, including /api/.
Empty localApiBaseUrl uses the device command fallback; explicit Dart URLs take priority.
.env only supplies launch tools/options: APP_ENV, API_PORT (default 8001), FLUTTER_BIN, ADB_BIN.
Shell variables override .env. APP_ENV is optional; changes to launch options require relaunch.
App configuration is public. Never embed secrets in Dart, .env assets or --dart-define.
EOF
}

require_flutter() {
  command -v "${FLUTTER_BIN:-flutter}" >/dev/null || {
    printf 'Flutter is not installed or not on PATH.\n' >&2
    exit 1
  }
}

flutter_cmd() {
  "${FLUTTER_BIN:-flutter}" "$@"
}

load_launch_options() {
  local initial="${APP_ENV-}" port="${API_PORT-}"
  local flutter="${FLUTTER_BIN-}" adb="${ADB_BIN-}"
  if [[ -f .env ]]; then source .env; fi
  APP_ENV="${initial:-${APP_ENV:-}}"
  API_PORT="${port:-${API_PORT:-8001}}"
  FLUTTER_BIN="${flutter:-${FLUTTER_BIN:-flutter}}"
  ADB_BIN="${adb:-${ADB_BIN:-adb}}"
}

configure_api_defines() {
  local fallback="$1"
  API_DEFINES=("--dart-define=LOCAL_API_FALLBACK=$fallback")
  if [[ -n "${APP_ENV:-}" ]]; then
    case "$APP_ENV" in
      local|test|production) ;;
      *) printf 'APP_ENV must be local, test or production.\n' >&2; exit 1 ;;
    esac
    API_DEFINES+=("--dart-define=APP_ENV=$APP_ENV")
  fi
}

run_app() {
  local fallback="$1"
  shift
  configure_api_defines "$fallback"
  exec "${FLUTTER_BIN:-flutter}" run "${API_DEFINES[@]}" "$@"
}

build_release() {
  printf 'Release API configuration comes from lib/app/config/app_config.dart; configure the selected HTTPS endpoint before distribution.\n'
  configure_api_defines ''
  exec "${FLUTTER_BIN:-flutter}" build "$@" --release "${API_DEFINES[@]}"
}

command="${1:-run}"
if [[ $# -gt 0 ]]; then shift; fi
if [[ "$command" == help || "$command" == -h || "$command" == --help ]]; then
  usage
  exit 0
fi
load_launch_options
require_flutter
case "$command" in
  init)
    if [[ ! -f .env ]]; then cp .env.example .env; fi
    flutter_cmd pub get
    flutter_cmd gen-l10n
    ;;
  run)
    run_app '' "$@"
    ;;
  android)
    run_app "http://10.0.2.2:${API_PORT:-8001}/api/" "$@"
    ;;
  usb)
    adb_bin="${ADB_BIN:-adb}"
    command -v "$adb_bin" >/dev/null || { printf 'adb is not on PATH.\n' >&2; exit 1; }
    device_id="${1:-}"
    if [[ -n "$device_id" ]]; then shift; else device_id="$("$adb_bin" -d get-serialno)"; fi
    "$adb_bin" -s "$device_id" reverse "tcp:${API_PORT:-8001}" "tcp:${API_PORT:-8001}"
    run_app "http://127.0.0.1:${API_PORT:-8001}/api/" -d "$device_id" "$@"
    ;;
  ios)
    run_app "http://localhost:${API_PORT:-8001}/api/" "$@"
    ;;
  web)
    run_app "http://localhost:${API_PORT:-8001}/api/" -d chrome --web-port 8080 "$@"
    ;;
  devices)
    flutter_cmd devices "$@"
    ;;
  l10n)
    flutter_cmd gen-l10n
    ;;
  icons)
    flutter_cmd test tool/generate_icons.dart
    ;;
  apk|appbundle|ipa)
    build_release "$command" "$@"
    ;;
  test)
    flutter_cmd test "$@"
    ;;
  lint)
    flutter_cmd analyze "$@"
    ;;
  format)
    command -v dart >/dev/null || { printf 'dart is not on PATH.\n' >&2; exit 1; }
    exec dart format lib test
    ;;
  clean)
    flutter_cmd clean
    ;;
  *)
    printf 'Unknown command: %s\n' "$command" >&2
    usage >&2
    exit 1
    ;;
esac
