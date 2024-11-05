#!/bin/bash

# Set the source branch for the wolfSSL changes
wolfssl_branch="wolfssl"
script_name=$(basename "$0")  # Get the script's own name

# Check if a tag was provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <release-tag>"
  echo "Please specify a release tag (e.g., v4.6.1) to generate patches against."
  exit 1
fi

release_tag=$1

# Fetch tags from upstream to ensure the specified tag is available
echo "Fetching tags from upstream..."
git fetch upstream --tags

# Verify that the specified tag exists
if ! git rev-parse "$release_tag" >/dev/null 2>&1; then
  echo "Tag '$release_tag' does not exist. Please specify a valid tag."
  exit 1
fi

# Check if the current branch matches the specified wolfSSL branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != "$wolfssl_branch" ]]; then
  echo "Please checkout the '$wolfssl_branch' branch before running this script."
  exit 1
fi

# Define output file names, incorporating only the tag name
commit_info_patch="sqlcipher_wolfssl_${release_tag}_gitinfo.patch"
raw_diff_patch="sqlcipher_wolfssl_${release_tag}_raw.patch"

# Generate the patch with full commit information, excluding the script itself
echo "Generating patch with commit information against tag '$release_tag'..."
git format-patch "$release_tag"..$wolfssl_branch --stdout -- ":!$script_name" > "$commit_info_patch"
echo "Created $commit_info_patch with full commit info."

# Generate the patch with only raw code changes, excluding the script itself
echo "Generating raw code changes patch against tag '$release_tag'..."
git diff "$release_tag"...$wolfssl_branch -- ":!$script_name" > "$raw_diff_patch"
echo "Created $raw_diff_patch with raw code changes only."

echo "Patch generation complete."

