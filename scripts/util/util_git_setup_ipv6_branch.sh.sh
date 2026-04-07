#!/bin/bash
################################################################################
# File Name: util_git_create_ipv6_integration.sh
# Intended use: Create a combined IPv6 branch by merging all relevant 
#               upstream IPv6 feature branches.
#
# Notes: This script supports Linux Bash shell only.
#        It follows a logical order: Protocol -> Management -> Client -> Security.
#
# Copyright (C) 2015 - 2026, CT129 Dev Team <dev@ct129.com>
################################################################################

# 1. Configuration
export TARGET_BRANCH="master"
export BASE_BRANCH="main"
export ORIGIN_NAME="vgisc"

# List of IPv6 branches in logical merge order
IPV6_BRANCHES=(
    "proto-ipv6-overlay"       # Core protocol support
    "mgmt-ipv6-addressing"     # Management & IP allocation
    "client-ipv6-iface"        # Interface configuration
    "client-ipv6-routing"      # Routing logic
    "client-ipv6-dns"          # DNS support
    "client-ipv6-nftables"     # Firewall support (nftables)
    "client-ipv6-acl-usp"      # Access Control Lists
    "client-ipv6-ssh-netflow"  # Internal SSH & telemetry
)

export TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export SCRIPT=$(readlink -f "$0")
export SCRIPT_PATH=$(dirname "$SCRIPT")
export SRC_DIR=$(readlink -f "${SCRIPT_PATH}/../..")

echo "------------------------------------------------------------------------"
echo "Git Automation: Creating IPv6 Integration Branch [${TARGET_BRANCH}]"
echo "------------------------------------------------------------------------"

# 2. Navigate to Source Directory
cd "${SRC_DIR}" || { echo "[ERROR] Cannot access ${SRC_DIR}"; exit 1; }

# 3. Prepare the Target Branch
echo "[INFO] Checking out ${BASE_BRANCH}..."
git checkout "${BASE_BRANCH}" --quiet
git pull "${ORIGIN_NAME}" "${BASE_BRANCH}" --quiet

# Delete branch if exists locally to start fresh
if git branch | grep -q "${TARGET_BRANCH}"; then
    echo "[INFO] Removing existing local branch ${TARGET_BRANCH}..."
    git branch -D "${TARGET_BRANCH}" --quiet
fi

echo "[INFO] Creating new branch ${TARGET_BRANCH} from ${BASE_BRANCH}..."
git checkout -b "${TARGET_BRANCH}"

# 4. Sequential Merge Process
for branch in "${IPV6_BRANCHES[@]}"; do
    echo "------------------------------------------------------------------------"
    echo "[MERGE] Integrating branch: ${branch}"
    
    # Check if branch exists on remote vgisc
    if ! git branch -r | grep -q "${ORIGIN_NAME}/${branch}"; then
        echo "[WARN] Branch ${branch} not found on ${ORIGIN_NAME}. Skipping..."
        continue
    fi

    # Attempt to merge
    if git merge "${ORIGIN_NAME}/${branch}" -m "Merge branch '${branch}' into ${TARGET_BRANCH}"; then
        echo "[SUCCESS] Merged ${branch} successfully."
    else
        echo "[ERROR] Conflict detected while merging ${branch}."
        echo "[ACTION] Please resolve conflicts manually, then run: git commit"
        echo "[ACTION] After resolving, re-run this script or continue merging manually."
        exit 1
    fi
done

# 5. Finalize
echo "------------------------------------------------------------------------"
echo "[INFO] Pushing ${TARGET_BRANCH} to ${ORIGIN_NAME}..."
git push "${ORIGIN_NAME}" "${TARGET_BRANCH}" --force

echo ""
echo "------------------------------------------------------------------------"
echo "===> IPv6 Integration process finished at ${TIMESTAMP}"
echo "New branch [${TARGET_BRANCH}] is now available on ${ORIGIN_NAME}."
echo "------------------------------------------------------------------------"
################################################################################
#                                     BASH SCRIPT ON LINUX/UNIX - END
################################################################################