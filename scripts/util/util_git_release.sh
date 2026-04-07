#!/bin/bash
################################################################################
# Intended use: Create and push a git tag for stable releases (Cyguard).
#
# Notes: This script supports Linux Bash shell script only.
#
# Copyright (C) 2015 - 2026, CT129 Dev Team <dev@ct129.com>
################################################################################

# 1. Configuration
export GIT_BRANCH="nb-v0.49.0"
export REMOTE_NAME="vgisc"

# Current date suffix (e.g., 20260325)
export DATE_SUFFIX=$(date +"%Y%m%d")
# Example Tag: v0.67.0-nb-v0.49.0-20260325
export GIT_TAG="v0.67.0-nb-v0.49.0-${DATE_SUFFIX}"

export TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export SCRIPT=$(readlink -f "$0")
export SCRIPT_PATH=$(dirname "$SCRIPT")
export SRC_DIR=$(readlink -f "${SCRIPT_PATH}/../..")

echo "------------------------------------------------------------------------"
echo "Cyguard Release Tool: Tagging ${GIT_TAG}"
echo "------------------------------------------------------------------------"

cd "${SRC_DIR}" || { echo "[ERROR] Cannot access ${SRC_DIR}"; exit 1; }

# 2. Ensure we are on the correct branch and have latest changes
git checkout "${GIT_BRANCH}"
git add .

# Commit if there are changes
if ! git diff --cached --quiet; then
    echo "[INFO] Committing remaining changes..."
    git commit -m "Release: ${GIT_TAG} at ${TIMESTAMP}"
fi

# 3. Handle Tag operations
echo "[INFO] Managing Tag: ${GIT_TAG}"

# Delete local tag if exists
if git rev-parse "${GIT_TAG}" >/dev/null 2>&1; then
    echo "[INFO] Deleting existing local tag..."
    git tag -d "${GIT_TAG}"
fi

# Delete remote tag if exists (to allow re-tagging the same version)
echo "[INFO] Cleaning remote tag if exists on ${REMOTE_NAME}..."
git push "${REMOTE_NAME}" ":refs/tags/${GIT_TAG}" 2>/dev/null

# 4. Create and Push new Tag
echo "[INFO] Creating new annotated tag..."
git tag -a "${GIT_TAG}" -m "Stable Release ${GIT_TAG} - ${TIMESTAMP}"

echo "[INFO] Pushing branch and tags to ${REMOTE_NAME}..."
git push "${REMOTE_NAME}" "${GIT_BRANCH}"
git push "${REMOTE_NAME}" --tags

echo "------------------------------------------------------------------------"
echo "===> Release ${GIT_TAG} successful!"
echo "------------------------------------------------------------------------"
################################################################################
#                                        BASH SCRIPT ON LINUX/UNIX - END
################################################################################