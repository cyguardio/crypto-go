#!/bin/bash
################################################################################
# Intended use: Automate fetching tags from upstream and pushing to origin.
#
# Notes: This script supports Linux Bash shell only.
#
# Copyright (C) 2015 - 2026, CT129 Dev Team <dev@ct129.com>
################################################################################

# 1. Configuration
export UPSTREAM_URL="git@github.com:golang/crypto.git"
export UPSTREAM_NAME="upstream"
export ORIGIN_NAME="vgisc"  # Tên remote trỏ về GitLab của bạn

export TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export SCRIPT=$(readlink -f "$0")
export SCRIPT_PATH=$(dirname "$SCRIPT")
export SRC_DIR=$(readlink -f "${SCRIPT_PATH}/../..")

echo "------------------------------------------------------------------------"
echo "Cyguard Git Automation: Syncing tags from ${UPSTREAM_NAME} to ${ORIGIN_NAME}"
echo "------------------------------------------------------------------------"

# 2. Navigate to Source Directory
cd "${SRC_DIR}" || { echo "[ERROR] Cannot access ${SRC_DIR}"; exit 1; }

# 3. Ensure Remotes are configured
# Check Upstream
if ! git remote | grep -q "^${UPSTREAM_NAME}$"; then
    echo "[INFO] Adding upstream remote: ${UPSTREAM_URL}"
    git remote add "${UPSTREAM_NAME}" "${UPSTREAM_URL}"
fi

# Check Origin (GitLab)
if ! git remote | grep -q "^${ORIGIN_NAME}$"; then
    echo "[ERROR] Remote '${ORIGIN_NAME}' (origin) not found."
    echo "Please run: git remote add ${ORIGIN_NAME} git@github.com:cyguardio/crypto-go.git"
    exit 1
fi

# 4. Sync Tags Operations
echo "[INFO] Fetching all tags from ${UPSTREAM_NAME}..."
git fetch "${UPSTREAM_NAME}" --tags

# Get count of tags for logging
TAG_COUNT=$(git tag | wc -l)
echo "[INFO] Total tags currently in local: ${TAG_COUNT}"

echo "[INFO] Pushing tags to ${ORIGIN_NAME} (GitLab)..."
# Sử dụng --tags để đẩy toàn bộ tag lên GitLab
git push "${ORIGIN_NAME}" --tags

echo ""
echo "------------------------------------------------------------------------"
echo "===> Git tags update process finished at ${TIMESTAMP}"
echo "------------------------------------------------------------------------"
################################################################################
#                                     BASH SCRIPT ON LINUX/UNIX - END
################################################################################