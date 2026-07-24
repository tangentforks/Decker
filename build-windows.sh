#!/usr/bin/env bash
# Build native Lilt / Decker on Windows with MSVC-targeted Clang and ./deps SDL2.
#
# Prerequisites:
#   - LLVM Clang on PATH (x86_64-pc-windows-msvc)
#   - deps/SDL2 and deps/SDL2_image from the official *-VC.zip packages
#   - xxd (e.g. Git for Windows) if regenerating c/resources.h
#
# Examples (Git Bash):
#   ./build-windows.sh
#   ./build-windows.sh lilt
#   ./build-windows.sh decker --danger
#   ./build-windows.sh all --danger --rebuild-resources
#   ./build-windows.sh decker --debug

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

TARGET="all"
DANGER=0
REBUILD_RESOURCES=0
CONFIGURATION="Release"

usage() {
	cat <<'EOF'
Usage: ./build-windows.sh [lilt|decker|all] [options]

Options:
  --danger              Enable Danger Zone (-DDANGER_ZONE)
  --rebuild-resources   Force regenerate c/resources.h
  --debug               Build with -O0 -g (default is -O2)
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		lilt|decker|all)
			TARGET="$1"
			shift
			;;
		--danger)
			DANGER=1
			shift
			;;
		--rebuild-resources)
			REBUILD_RESOURCES=1
			shift
			;;
		--debug)
			CONFIGURATION="Debug"
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage >&2
			exit 1
			;;
	esac
done

require_cmd() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Required command not found on PATH: $1" >&2
		exit 1
	fi
}

ensure_resources() {
	if [[ "$REBUILD_RESOURCES" -eq 0 && -f c/resources.h ]]; then
		echo "Using existing c/resources.h"
		return
	fi
	require_cmd xxd
	echo "Generating c/resources.h ..."
	chmod +x ./scripts/resources.sh
	./scripts/resources.sh examples/decks/tour.deck
}

version_string() {
	tr -d ' \t\r\n' < VERSION
}

build_lilt() {
	echo "Building c/build/lilt.exe ..."
	# shellcheck disable=SC2086
	clang c/lilt.c -o c/build/lilt.exe -lshlwapi $COMMON_FLAGS
	echo "OK  c/build/lilt.exe"
}

copy_runtime_dlls() {
	local src
	for src in deps/SDL2/lib/x64/SDL2.dll deps/SDL2_image/lib/x64/SDL2_image.dll; do
		if [[ ! -f "$src" ]]; then
			echo "Missing runtime DLL: $src" >&2
			exit 1
		fi
		cp -f "$src" c/build/
	done
	if [[ -d deps/SDL2_image/lib/x64/optional ]]; then
		cp -f deps/SDL2_image/lib/x64/optional/*.dll c/build/ 2>/dev/null || true
	fi
}

build_decker() {
	local p
	for p in \
		deps/SDL2/include/SDL.h \
		deps/SDL2_image/include/SDL_image.h \
		deps/SDL2/lib/x64/SDL2.lib \
		deps/SDL2_image/lib/x64/SDL2_image.lib
	do
		if [[ ! -f "$p" ]]; then
			echo "Missing SDL dependency: $p" >&2
			echo "Download the official *-VC.zip packages into deps/." >&2
			exit 1
		fi
	done

	echo "Building c/build/decker.exe ..."
	# shellcheck disable=SC2086
	clang c/decker.c -o c/build/decker.exe \
		-Ideps/SDL2/include \
		-Ideps/SDL2_image/include \
		-Ldeps/SDL2/lib/x64 \
		-Ldeps/SDL2_image/lib/x64 \
		-lSDL2 -lSDL2_image -lshlwapi \
		-DSDL_MAIN_HANDLED \
		$COMMON_FLAGS
	copy_runtime_dlls
	echo "OK  c/build/decker.exe (+ SDL DLLs)"
}

require_cmd clang
mkdir -p c/build
ensure_resources

VERSION="$(version_string)"
if [[ -z "$VERSION" ]]; then
	echo "VERSION file is empty" >&2
	exit 1
fi

COMMON_FLAGS="-std=c99 -Wno-misleading-indentation -D_CRT_SECURE_NO_WARNINGS -DVERSION=\"$VERSION\""
if [[ "$CONFIGURATION" == "Release" ]]; then
	COMMON_FLAGS="$COMMON_FLAGS -O2"
else
	COMMON_FLAGS="$COMMON_FLAGS -O0 -g"
fi
if [[ "$DANGER" -eq 1 ]]; then
	COMMON_FLAGS="$COMMON_FLAGS -DDANGER_ZONE"
	echo "Danger Zone enabled (-DDANGER_ZONE)"
fi

echo "VERSION=$VERSION  Target=$TARGET  Configuration=$CONFIGURATION"

case "$TARGET" in
	lilt)
		build_lilt
		;;
	decker)
		build_decker
		;;
	all)
		build_lilt
		build_decker
		;;
esac

echo "Done."
case "$TARGET" in
	lilt|all) echo "  ./c/build/lilt.exe" ;;
esac
case "$TARGET" in
	decker|all)
		echo "  ./c/build/decker.exe"
		if [[ "$DANGER" -eq 1 ]]; then
			echo "  (danger mode build)"
		fi
		;;
esac
