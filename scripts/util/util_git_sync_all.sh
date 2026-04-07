#!/bin/bash
################################################################################
# Intended use: Synchronize all branches and tags from upstream to vgisc remote.
#
# Notes: This script supports Linux Bash shell only.
#        It preserves your custom branches on vgisc by only pushing branches
#        that exist in the upstream repository.
#
# Copyright (C) 2015 - 2026, CT129 Dev Team <dev@ct129.com>
################################################################################

# 1. Configuration
export UPSTREAM_NAME="upstream"
export ORIGIN_NAME="vgisc"

export TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export SCRIPT=$(readlink -f "$0")
export SCRIPT_PATH=$(dirname "$SCRIPT")
export SRC_DIR=$(readlink -f "${SCRIPT_PATH}/../..")

echo "------------------------------------------------------------------------"
echo "Git Automation: Syncing ALL Upstream Branches & Tags to ${ORIGIN_NAME}"
echo "------------------------------------------------------------------------"

# 2. Navigate to Source Directory
cd "${SRC_DIR}" || { echo "[ERROR] Cannot access ${SRC_DIR}"; exit 1; }

# 3. Fetch all updates from Upstream
echo "[INFO] Fetching all data from ${UPSTREAM_NAME}..."
# Fetch all branches and tags, pruning deleted ones from remote tracking
git fetch "${UPSTREAM_NAME}" --prune --tags --quiet

# 4. Sync All Upstream Branches to Origin
echo "[INFO] Starting batch synchronization of branches..."

# Get all remote branches from upstream and push them to vgisc
# Format: refs/remotes/upstream/branch-name -> refs/heads/branch-name
git branch -r | grep "${UPSTREAM_NAME}/" | grep -v "HEAD" | while read -r remote_branch; do
    # Extract the branch name (e.g., 'upstream/main' -> 'main')
    branch_name="${remote_branch#${UPSTREAM_NAME}/}"
    
    echo "[SYNC] Pushing ${branch_name} to ${ORIGIN_NAME}..."
    
    # We use force to ensure the tracking branches on vgisc match upstream exactly.
    # This only affects branches that exist on both upstream and vgisc.
    git push "${ORIGIN_NAME}" "${remote_branch}:refs/heads/${branch_name}" --force --quiet
done

# 5. Sync All Tags
echo "[INFO] Pushing all tags to ${ORIGIN_NAME}..."
# This will push all local tags to the internal GitLab
git push "${ORIGIN_NAME}" --tags --force --quiet

echo ""
echo "------------------------------------------------------------------------"
echo "===> Global sync process finished successfully at ${TIMESTAMP}"
echo "Note: Only branches originating from ${UPSTREAM_NAME} were updated."
echo "Your custom branches on ${ORIGIN_NAME} (e.g., nb-v0.49.0) are safe."
echo "------------------------------------------------------------------------"
################################################################################
#                                     BASH SCRIPT ON LINUX/UNIX - END
################################################################################