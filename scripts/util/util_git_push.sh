#!/bin/bash
################################################################################
# Intended use: Automate git add, commit and push for Cyguard project.
#
# Notes: This script supports Linux Bash shell only.
#
# Copyright (C) 2015 - 2026, CT129 Dev Team <dev@ct129.com>
################################################################################

# 1. Configuration - Update branch name to your current working branch
export GIT_BRANCH="master"
export REMOTE_NAME="vgisc"

export TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export SCRIPT=$(readlink -f "$0")
export SCRIPT_PATH=$(dirname "$SCRIPT")
export SRC_DIR=$(readlink -f "${SCRIPT_PATH}/../..")

echo "------------------------------------------------------------------------"
echo "Cyguard Git Automation: Preparing to push to ${REMOTE_NAME}/${GIT_BRANCH}"
echo "------------------------------------------------------------------------"

# 2. Navigate to Source Directory
cd "${SRC_DIR}" || { echo "[ERROR] Cannot access ${SRC_DIR}"; exit 1; }

# 3. Check if remote exists
if ! git remote | grep -q "^${REMOTE_NAME}$"; then
    echo "[ERROR] Remote '${REMOTE_NAME}' not found. Please run:"
    echo "git remote add ${REMOTE_NAME} https://gitlab.ct129.com/vgisc/vpn/netbird.git"
    exit 1
fi

# 4. Git Operations
echo "[INFO] Adding changes..."
git add .

# Only commit if there are changes to avoid error exit codes
if git diff --cached --quiet; then
    echo "[INFO] No changes to commit."
else
    echo "[INFO] Committing changes with timestamp: ${TIMESTAMP}"
    git commit -m "Update: ${TIMESTAMP}"
fi

echo "[INFO] Pushing to ${REMOTE_NAME} branch ${GIT_BRANCH}..."
git push -u "${REMOTE_NAME}" "${GIT_BRANCH}"

echo ""
echo "===> Git push process finished."
################################################################################
#                                        BASH SCRIPT ON LINUX/UNIX - END
################################################################################s