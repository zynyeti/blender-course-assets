#!/bin/bash
# Syncs new images from the Blender course "Pic for doc" staging folder into
# blender-course-assets/_review/ (compressed JPG) and pushes to GitHub, so
# Claude can pull them via raw.githubusercontent.com for style/placement review.
# This is a SCRATCH review space, separate from the final hosted asset
# folders (/blenderville/, /ancient-history/, etc.) — nothing here is final.
#
# Mirrors subfolder structure: if a project has its own subfolder under
# "Pic for doc" (e.g. "Pic for doc/RubiksCube/"), it's mirrored into
# "_review/RubiksCube/" so it can be pruned per-project once complete
# (see prune_review.sh). Loose files directly in "Pic for doc" go into
# "_review/" root (unsorted).
set -e
SRC="/home/greissner/Documents/Projects/Pic for doc"
DEST="/home/greissner/blender-course-assets/_review"
cd /home/greissner/blender-course-assets

shopt -s nullglob globstar
for f in "$SRC"/**/*.png "$SRC"/**/*.jpg "$SRC"/**/*.jpeg; do
  [ -f "$f" ] || continue
  rel="${f#$SRC/}"
  reldir=$(dirname "$rel")
  base=$(basename "$rel")
  name="${base%.*}"
  if [ "$reldir" = "." ]; then
    outdir="$DEST"
  else
    outdir="$DEST/$reldir"
  fi
  mkdir -p "$outdir"
  out="$outdir/${name}.jpg"
  if [ ! -f "$out" ]; then
    python3 -c "
from PIL import Image
img = Image.open('$f')
img.convert('RGB').save('$out', 'JPEG', quality=85, optimize=True)
"
    echo "Synced: $rel -> _review/${reldir#./}/${name}.jpg"
  fi
done

git add _review/
if ! git diff --cached --quiet; then
  git commit -m "review sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push
  echo "Pushed."
else
  echo "Nothing new to push."
fi
