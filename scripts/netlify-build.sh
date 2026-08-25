#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
flutter_version="${FLUTTER_VERSION:-3.47.1}"
cache_dir="${NETLIFY_CACHE_DIR:-${HOME}/.cache}"
flutter_dir="${cache_dir}/flutter-${flutter_version}"
archive_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz"
temporary_dir=""
git_wrapper_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${git_wrapper_dir}"
  if [[ -n "${temporary_dir}" ]]; then
    rm -rf "${temporary_dir}"
  fi
}

trap cleanup EXIT

if [[ ! -x "${flutter_dir}/bin/flutter" ]]; then
  temporary_dir="$(mktemp -d)"

  echo "Installing Flutter ${flutter_version}..."
  curl --fail --location --retry 3 --output "${temporary_dir}/flutter.tar.xz" "${archive_url}"
  tar --extract --xz --file "${temporary_dir}/flutter.tar.xz" --directory "${temporary_dir}"
  mkdir -p "${cache_dir}"
  rm -rf "${flutter_dir}"
  mv "${temporary_dir}/flutter" "${flutter_dir}"
fi

version_manifest="${flutter_dir}/bin/cache/flutter.version.json"

node - "${version_manifest}" "${flutter_version}" <<'NODE'
const fs = require('node:fs');

const [manifestPath, flutterVersion] = process.argv.slice(2);
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

manifest.frameworkVersion = flutterVersion;
manifest.flutterVersion = flutterVersion;
manifest.channel = 'stable';
manifest.repositoryUrl = 'https://github.com/flutter/flutter.git';

fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
NODE

export NETLIFY_SYSTEM_GIT="$(command -v git)"
ln -s "${script_dir}/flutter-git-wrapper.sh" "${git_wrapper_dir}/git"

export PATH="${flutter_dir}/bin:${git_wrapper_dir}:${PATH}"
export PUB_CACHE="${cache_dir}/dart-pub-cache"

flutter config --no-analytics
flutter pub get
flutter build web --release
