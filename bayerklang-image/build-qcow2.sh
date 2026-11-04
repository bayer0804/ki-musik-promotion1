#!/usr/bin/env bash
set -Eeuo pipefail
export LIBGUESTFS_BACKEND=direct
export LIBGUESTFS_MEMSIZE=4096
ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$ROOT/build" "$ROOT/output"
KEY="$ROOT/BayerKI_TEMP_PUBLIC.pub"
BASE="https://cloud-images.ubuntu.com/noble/current"
NAME="noble-server-cloudimg-amd64.img"
OUT="BAYERKLANG-KI-Desktop-1.0-Ubuntu-24.04.qcow2"
for c in curl sha256sum qemu-img virt-customize virt-sysprep; do command -v "$c" >/dev/null || { echo "Missing $c"; exit 2; }; done
test -r "$KEY"
grep -q '^ssh-ed25519 AAAA' "$KEY" || { echo "No public Ed25519 key"; exit 2; }
echo "Downloading official Ubuntu image"
curl -fL --retry 3 -o "$ROOT/build/SHA256SUMS" "$BASE/SHA256SUMS"
curl -fL --retry 3 -o "$ROOT/build/$NAME" "$BASE/$NAME"
EXPECTED="$(awk -v target="$NAME" '{gsub(/^\*/, "", $2); if ($2==target) {print $1; exit}}' "$ROOT/build/SHA256SUMS")"
ACTUAL="$(sha256sum "$ROOT/build/$NAME" | cut -d ' ' -f 1)"
test -n "$EXPECTED" && test "$EXPECTED" = "$ACTUAL" || { echo "Checksum mismatch"; exit 3; }
cp "$ROOT/build/$NAME" "$ROOT/build/work.qcow2"
qemu-img resize "$ROOT/build/work.qcow2" 32G
virt-customize -a "$ROOT/build/work.qcow2" --no-network --upload "$KEY:/root/bayerklang-public.pub" --run "$ROOT/configure-guest.sh"
virt-sysprep -a "$ROOT/build/work.qcow2" --operations machine-id,ssh-hostkeys
qemu-img convert -p -f qcow2 -O qcow2 -c "$ROOT/build/work.qcow2" "$ROOT/output/$OUT"
qemu-img check "$ROOT/output/$OUT"
cd "$ROOT/output"
sha256sum "$OUT" > "$OUT.sha256"
qemu-img info "$OUT"
echo "Image built; DO NOT install without test boot and confirmation."
