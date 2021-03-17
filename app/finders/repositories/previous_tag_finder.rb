# frozen_string_literal: true

module Repositories
  # A finder class for getting the tag of the last release before a given
  # version.
  #
  # Imagine a project with the following tags:
  #
  # * v1.0.0
  # * v1.1.0
  # * v2.0.0
  #
  # If the version supplied is 2.1.0, the tag returned will be v2.0.0. And when
  # the version is 1.1.1, or 1.2.0, the returned tag will be v1.1.0.
  #
  # To obtain the tags, this finder requires a regular expression (using the re2
  # syntax) to be provided. This regex must produce the following named
  # captures:
  #
  # - major (required)
  # - minor (required)
  # - patch (required)
  # - prerelease
  # - buildmetadata
  #
  # If the `prerelease` group has a value, the tag is ignored. If any of the
  # required capture groups don't have a value, the tag is also ignored.
  class PreviousTagFinder
    # The regex to use for extracting the version from a Git tag.
    #
    # This regex is based on the official semantic versioning regex (as found on
    # https://semver.org/), with the addition of allowing a "v" at the start of
    # a tag name.
    #
    # We default to a strict regex as we simply don't know what kind of data
    # users put in their tags. As such, using simpler patterns (e.g. just `\d+`
    # for the major version) could lead to unexpected results.
    #
    # We use a String here as `Gitlab::UntrustedRegexp` is a mutable object.
    DEFAULT_TAG_REGEX = '^v?(?P<major>0|[1-9]\d*)' \
      '\.(?P<minor>0|[1-9]\d*)' \
      '\.(?P<patch>0|[1-9]\d*)' \
      '(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))' \
      '?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'

    def initialize(project, regex: DEFAULT_TAG_REGEX)
      @project = project
      @regex = regex
    end

    def execute(new_version)
      tags = {}
      versions = [new_version]
      regex = Gitlab::UntrustedRegexp.new(@regex)

      @project.repository.tags.each do |tag|
        matches = regex.match(tag.name)

        next unless matches

        # When using this class for generating changelog data for a range of
        # commits, we want to compare against the tag of the last _stable_
        # release; not some random RC that came after that.
        next if matches[:prerelease]

        major = matches[:major]
        minor = matches[:minor]
        patch = matches[:patch]
        build = matches[:buildmetadata]

        next unless major && minor && patch

        version = "#{major}.#{minor}.#{patch}"
        version += "+#{build}" if build

        tags[version] = tag
        versions << version
      end

      VersionSorter.sort!(versions)

      index = versions.index(new_version)

      tags[versions[index - 1]] if index&.positive?
    end
  end
end
