#!/bin/bash
#===============================================================
# SCRIPT   : run-daemon.sh
# PURPOSE  : Build and launch the COBOL Event Daemon
# AUTHOR   : Jhon Hanco (TheSrJohns)
# GITHUB   : https://github.com/TheSrJohns
#===============================================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$PROJECT_DIR"
BUILD_DIR="$PROJECT_DIR/build"

echo "========================================"
echo " COBOL Payment Processor Daemon"
echo " Author : Jhon Hanco (TheSrJohns)"
echo "========================================"

# Create build directory
mkdir -p "$BUILD_DIR"

# Compile copybook (included, no separate compile needed)
echo "[BUILD] Copybook AUTH-DTO.cpy is ready."

# Compile Infrastructure layer
echo "[BUILD] Compiling Infrastructure layer..."
cobc -c -o "$BUILD_DIR/JSON-SERVICE.o"   "$SRC_DIR/infraestructura/JSON-SERVICE.cbl"   -I "$SRC_DIR/copybooks"
cobc -c -o "$BUILD_DIR/AUDIT-REPO.o"   "$SRC_DIR/infraestructura/AUDIT-REPO.cbl"   -I "$SRC_DIR/copybooks"

# Compile Services layer
echo "[BUILD] Compiling Services layer..."
cobc -c -o "$BUILD_DIR/SECURITY-SERVICE.o" "$SRC_DIR/servicios/SECURITY-SERVICE.cbl" -I "$SRC_DIR/copybooks"

# Compile Controller layer
echo "[BUILD] Compiling Controller layer..."
cobc -x -o "$BUILD_DIR/event-daemon" "$SRC_DIR/controlador/EVENT-DAEMON.cbl"     "$BUILD_DIR/JSON-SERVICE.o"     "$BUILD_DIR/AUDIT-REPO.o"     "$BUILD_DIR/SECURITY-SERVICE.o"     -I "$SRC_DIR/copybooks"

echo "[BUILD] Build complete."
echo ""
echo "[RUN] Starting EVENT-DAEMON..."
"$BUILD_DIR/event-daemon"
