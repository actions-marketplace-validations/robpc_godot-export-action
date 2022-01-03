#!/bin/bash
#################################################################
# update-godot.sh
#
# Automates the changes needed when adding/updating the version
# of Godot
#################################################################

# Arguments
VERSION=$1

if [ -z "${VERSION}" ]; then
    echo "ERROR: Missing version in first argument"
    exit 1
fi

# Files to change
DOCKERHUB_FILE=.github/workflows/dockerhub.yml
DOCKER_FILE=Dockerfile
README_FILE=README.md
ACTION_FILE=action.yml

if [ ! -f "${DOCKERHUB_FILE}" -o ! -f "${DOCKER_FILE}" -o ! -f "${README_FILE}" -o ! -f "${ACTION_FILE}" ]; then
    echo "ERROR: Could not find files, perhaps in the wrong directory?"
    exit 1
fi

VERSION_PATTERN='[0-9]+\.[0-9]+(\.[0-9]+)?'

# =====================
# Github Action
# =====================

# Update `env.latest`
sed --in-place --regexp-extended '/latest:/'"s/${VERSION_PATTERN}/${VERSION}/" "${DOCKERHUB_FILE}"
# Update `jobs.docker.strategy.matrix.version`
sed --in-place --regexp-extended '/version:/ { n; s/'"${VERSION_PATTERN}"'/'"${VERSION}"'/ }' "${DOCKERHUB_FILE}"

# =====================
# Dockerfile
# =====================

sed --in-place --regexp-extended '/ARG GODOT_VERSION=/'"s/${VERSION_PATTERN}/${VERSION}/" "${DOCKER_FILE}"

# =====================
# README
# =====================

# Example github action
sed --in-place --regexp-extended '/godot-export-action/'"s/${VERSION_PATTERN}/${VERSION}/" "${README_FILE}"
# List of older versions supported
legacy_version_expression='/Supported versions/ { 
    n;
    s/(.*)/`v'"${VERSION}"'`, \1/
}'
sed --in-place --regexp-extended "${legacy_version_expression}" "${README_FILE}"

# =====================
# Action
# =====================

# Update `runs.image`
sed --in-place --regexp-extended '/godot-export-action/'"s/${VERSION_PATTERN}/${VERSION}/" "${ACTION_FILE}"