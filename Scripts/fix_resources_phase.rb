#!/usr/bin/env ruby
# frozen_string_literal: true

# Works around an XcodeGen bug (reproduced against the current git HEAD build,
# 2026-08) where a target's `resources:` entries are parsed correctly from
# project.yml (confirmed via `xcodegen dump`) but never turn into an actual
# PBXResourcesBuildPhase or file reference in the generated project — so
# Resources/Assets.xcassets silently never gets compiled, and the app ships
# with no app icon and no accent color asset. `xcodegen generate` must always
# be followed by this script; see Scripts/generate_project.sh.
gem 'xcodeproj', '>= 1.27'
require 'xcodeproj'

project_path, target_name, resource_path = ARGV
if project_path.nil? || target_name.nil? || resource_path.nil?
  abort "Usage: #{$PROGRAM_NAME} <project.xcodeproj> <target name> <resource path relative to project root>"
end

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == target_name }
abort "Target #{target_name} not found in #{project_path}" unless target

phase = target.resources_build_phase # creates the phase if the target doesn't have one yet

# A flat reference directly on the main group (rather than nesting it inside
# a looked-up/created "Resources" subgroup) — nested groups created by
# find_subpath don't reliably carry a real on-disk path, which silently
# resolved the icon set to the wrong location the first time this was tried.
file_ref = project.main_group.files.find { |f| f.path == resource_path }
file_ref ||= project.main_group.new_reference(resource_path)

phase.add_file_reference(file_ref) unless phase.files_references.include?(file_ref)

project.save
puts "[fix_resources_phase] #{target_name}: #{file_ref.real_path} in Resources phase (#{phase.files.map { |f| f.file_ref.path }})"
