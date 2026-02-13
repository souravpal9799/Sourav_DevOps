#!/bin/bash

find /var/www -type d -name ".git" -print0 | while IFS= read -r -d '' gitdir; do
  repo=$(dirname "$gitdir")
  echo "📁 Repo Folder: $repo"
  echo "🔗 Git Remotes:"
  git -C "$repo" remote -v 2>/dev/null || echo "  (no remotes configured)"
  echo "----------------------------------------"
done
