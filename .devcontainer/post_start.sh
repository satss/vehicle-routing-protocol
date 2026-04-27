#!/bin/bash

readonly NRW_PBF_URL="https://download.geofabrik.de/europe/germany/nordrhein-westfalen-latest.osm.pbf"
readonly VALHALLA_CUSTOM_FILES_DIRECTORY_PATH="infra/valhalla/custom_files"
readonly VALHALLA_NRW_PBF_PATH="${VALHALLA_CUSTOM_FILES_DIRECTORY_PATH}/nordrhein-westfalen-latest.osm.pbf"

ensure_shell_history_works() {
  mkdir -p "${HIST_PERSIST_DIR}"
  touch "${HISTFILE}"
  chmod 600 "${HISTFILE}"
}
enable_commit_signing() {
  if [ -f /home/vscode/.ssh/commit-signing ]; then
    git config --global user.signingkey /home/vscode/.ssh/commit-signing
    git config --global commit.gpgsign true
    git config --global gpg.format ssh
  fi
}
should_show_nominatim_initial_setup_warning() {
  if docker container inspect local-nominatim >/dev/null 2>&1; then
    return 1
  fi

  if docker volume ls --format '{{.Name}}' | grep -Eq '(^|_)nominatim_database_data$'; then
    return 1
  fi

  return 0
}
ensure_local_nominatim_service_runs() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Skipping local Nominatim startup because Docker is not available."
    return
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "Skipping local Nominatim startup because the Docker daemon is unavailable."
    return
  fi

  if should_show_nominatim_initial_setup_warning; then
    echo "=================================================================="
    echo "WARNING: Local Nominatim initial setup may take significant time."
    echo "The first import downloads and processes NRW OSM data and can run"
    echo "for a long time depending on available machine resources."
    echo "=================================================================="
  fi

  if ! docker compose -f .devcontainer/docker-compose.location-services.yml up -d nominatim; then
    echo "Nominatim startup failed. Retry with: docker compose -f .devcontainer/docker-compose.location-services.yml up -d nominatim"
  fi
}
should_show_valhalla_initial_setup_warning() {
  if docker container inspect local-valhalla >/dev/null 2>&1; then
    return 1
  fi

  if [ -d "${VALHALLA_CUSTOM_FILES_DIRECTORY_PATH}/valhalla_tiles" ]; then
    return 1
  fi

  if [ -f "${VALHALLA_CUSTOM_FILES_DIRECTORY_PATH}/valhalla_tiles.tar" ]; then
    return 1
  fi

  return 0
}
download_valhalla_nrw_pbf_if_missing() {
  mkdir -p "${VALHALLA_CUSTOM_FILES_DIRECTORY_PATH}"

  if [ -f "${VALHALLA_NRW_PBF_PATH}" ]; then
    return 0
  fi

  echo "Downloading NRW OSM extract for local Valhalla into ${VALHALLA_NRW_PBF_PATH}."

  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --retry-delay 2 --output "${VALHALLA_NRW_PBF_PATH}" "${NRW_PBF_URL}"
    return $?
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "${VALHALLA_NRW_PBF_PATH}" "${NRW_PBF_URL}"
    return $?
  fi

  echo "Cannot download NRW PBF because neither curl nor wget is available."
  return 1
}
ensure_local_valhalla_service_runs() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Skipping local Valhalla startup because Docker is not available."
    return
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "Skipping local Valhalla startup because the Docker daemon is unavailable."
    return
  fi

  if should_show_valhalla_initial_setup_warning; then
    echo "=================================================================="
    echo "WARNING: Local Valhalla initial setup may take significant time."
    echo "The first startup downloads and builds NRW routing tiles and can"
    echo "run for a long time depending on available machine resources."
    echo "=================================================================="
  fi

  if ! download_valhalla_nrw_pbf_if_missing; then
    echo "Valhalla startup failed while downloading NRW PBF."
    echo "Retry with: curl -fL --output ${VALHALLA_NRW_PBF_PATH} ${NRW_PBF_URL} && docker compose -f .devcontainer/docker-compose.location-services.yml up -d valhalla"
    return
  fi

  if ! docker compose -f .devcontainer/docker-compose.location-services.yml up -d valhalla; then
    echo "Valhalla startup failed. Retry with: docker compose -f .devcontainer/docker-compose.location-services.yml up -d valhalla"
  fi
}

ensure_shell_history_works
enable_commit_signing
ensure_local_nominatim_service_runs
ensure_local_valhalla_service_runs
