#!/bin/bash
################################################################################
# Intended use: Fetch tags from upstream and update local main to latest tag.
#
# Notes: This script supports Linux Bash shell only.
#        WARNING: This will overwrite local 'main' branch with latest tag code.
#
# Copyright (C) 2015 - 2026, CT129 Dev Team <dev@ct129.com>
################################################################################

# 1. Configuration
export UPSTREAM_URL="git@github.com:golang/crypto.git"
export UPSTREAM_NAME="upstream"
export ORIGIN_NAME="vgisc"  # Remote pointing to your internal GitLab
export MAIN_BRANCH="main"    # Your main branch name

export TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export SCRIPT=$(readlink -f "$0")
export SCRIPT_PATH=$(dirname "$SCRIPT")
export SRC_DIR=$(readlink -f "${SCRIPT_PATH}/../..")

echo "------------------------------------------------------------------------"
echo "Git Automation: Updating ${MAIN_BRANCH} to Latest Upstream Tag"
echo "------------------------------------------------------------------------"

# 2. Navigate to Source Directory
cd "${SRC_DIR}" || { echo "[ERROR] Cannot access ${SRC_DIR}"; exit 1; }

# 3. Ensure Remotes are configured
# Check if upstream remote exists, if not, add it
if ! git remote | grep -q "^${UPSTREAM_NAME}$"; then
    echo "[INFO] Adding upstream remote: ${UPSTREAM_URL}"
    git remote add "${UPSTREAM_NAME}" "${UPSTREAM_URL}"
fi

# Check if origin remote (vgisc) exists
if ! git remote | grep -q "^${ORIGIN_NAME}$"; then
    echo "[ERROR] Remote '${ORIGIN_NAME}' (origin) not found."
    echo "Please ensure the remote is correctly configured."
    exit 1
fi

# 4. Sync Tags Operations
echo "[INFO] Fetching all tags from ${UPSTREAM_NAME}..."
git fetch "${UPSTREAM_NAME}" --tags --quiet

# 5. Identify Latest Tag
# Sort tags by version (vX.Y.Z) and pick the last one
LATEST_TAG=$(git tag -l "v*" | sort -V | tail -n 1)

if [ -z "$LATEST_TAG" ]; then
    echo "[ERROR] No tags found starting with 'v' from ${UPSTREAM_NAME}."
    exit 1
fi

echo "[INFO] Latest tag identified: ${LATEST_TAG}"

# 6. Update Main Branch
echo "[INFO] Switching to ${MAIN_BRANCH}..."
git checkout "${MAIN_BRANCH}" --quiet

# Safety check: ensure no uncommitted changes exist to avoid data loss
if ! git diff-index --quiet HEAD --; then
    echo "[ERROR] Uncommitted changes detected in ${MAIN_BRANCH}."
    echo "Please stash or commit your changes before running this script."
    exit 1
fi

echo "[INFO] Resetting ${MAIN_BRANCH} to ${LATEST_TAG}..."
# Force main to match the latest tag source code exactly
git reset --hard "${LATEST_TAG}"

# 7. Push to Internal GitLab (vgisc)
echo "[INFO] Pushing ${MAIN_BRANCH} and tags to ${ORIGIN_NAME}..."
# Force push is required because we reset the branch history
git push "${ORIGIN_NAME}" "${MAIN_BRANCH}" --force
git push "${ORIGIN_NAME}" --tags

echo ""
echo "------------------------------------------------------------------------"
echo "===> Process finished successfully at ${TIMESTAMP}"
echo "Current Status: ${MAIN_BRANCH} is now synchronized with ${LATEST_TAG}"
echo "------------------------------------------------------------------------"
################################################################################
#                                     BASH SCRIPT ON LINUX/UNIX - END
################################################################################