#!/bin/bash
# Removes a completed project's subfolder from _review/ once its images
# have been finalized (promoted to a real hosted folder, or discarded).
# Usage: ./prune_review.sh <ProjectSubfolderName>
set -e
cd /home/greissner/blender-course-assets
if [ -z "$1" ]; then
  echo "Usage: $0 <ProjectSubfolderName>"
  echo "Available: "
  ls _review/ 2>/dev/null
  exit 1
fi
TARGET="_review/$1"
if [ ! -d "$TARGET" ]; then
  echo "No such folder: $TARGET"
  exit 1
fi
git rm -r "$TARGET"
git commit -m "prune review: $1 complete"
git push
echo "Pruned $TARGET"
