# frozen_string_literal: true

require 'backup/files'

module Backup
  class Artifacts < Files
    attr_reader :progress

    def initialize(progress)
      @progress = progress

      super('artifacts', JobArtifactUploader.root, excludes: ['tmp'])
    end
  end
end
