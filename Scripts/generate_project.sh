#!/bin/bash
# Regenerates HockeyLineup.xcodeproj from project.yml.
#
# Always use this instead of a bare `xcodegen generate` — it also patches in
# the app target's Resources build phase, which XcodeGen currently fails to
# generate on its own (see Scripts/fix_resources_phase.rb for why). Without
# this, the app builds and runs fine but silently ships with no app icon and
# no accent color, since Resources/Assets.xcassets never gets compiled in.
set -euo pipefail
cd "$(dirname "$0")/.."

xcodegen generate

ruby Scripts/fix_resources_phase.rb \
  HockeyLineup.xcodeproj \
  HockeyLineup \
  Resources/Assets.xcassets
