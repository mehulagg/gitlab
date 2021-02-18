# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Copy routable here to avoid relying on application logic
    module Routable
      def build_full_path
        if parent && path
          parent.build_full_path + '/' + path
        else
          path
        end
      end
    end

    # Namespace
    class Namespace < ActiveRecord::Base
      self.table_name = 'namespaces'
      self.inheritance_column = :_type_disabled

      include Routable

      belongs_to :parent, class_name: "Namespace"
    end

    # copy class with only required code
    class Project < ActiveRecord::Base
      self.table_name = 'projects'
      self.inheritance_column = :_type_disabled

      include Routable

      belongs_to :namespace
      alias_method :parent, :namespace
      alias_attribute :parent_id, :namespace_id

      has_one :pages_metadatum, class_name: 'ProjectPagesMetadatum', inverse_of: :project

      def pages_path
        File.join(Settings.pages.path, build_full_path)
      end
    end

    # copy class with only required code
    class ProjectPagesMetadatum < ActiveRecord::Base
      self.table_name = 'project_pages_metadata'
      self.inheritance_column = :_type_disabled

      include EachBatch

      belongs_to :project, inverse_of: :pages_metadatum, class_name: 'Project'
      belongs_to :pages_deployment, class_name: 'PagesDeployment'

      scope :deployed, -> { where(deployed: true) }
      scope :only_on_legacy_storage, -> { deployed.where(pages_deployment: nil) }
      scope :with_project_route_and_deployment, -> { preload(:pages_deployment, project: [:namespace, :route]) }
    end

    # copy class with only required code
    class PagesDeployment < ActiveRecord::Base
      self.table_name = 'pages_deployments'
      self.inheritance_column = :_type_disabled

      include FileStoreMounter

      attribute :file_store, :integer, default: -> { ::Pages::DeploymentUploader.default_store }

      belongs_to :project, class_name: 'Project'

      validates :file, presence: true
      validates :file_store, presence: true, inclusion: { in: ObjectStorage::SUPPORTED_STORES }
      validates :size, presence: true, numericality: { greater_than: 0, only_integer: true }
      validates :file_count, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
      validates :file_sha256, presence: true

      before_validation :set_size, if: :file_changed?

      # Shall we copy all the uploader code migration as well?
      mount_file_store_uploader ::Pages::DeploymentUploader

      private

      def set_size
        self.size = file.size
      end
    end

    # migrates pages from legacy storage to zip format
    class MigratePagesToZipStorage
      def perform(start_id, stop_id)
        ProjectPagesMetadatum.only_on_legacy_storage.where(id: start_id..stop_id).each do |metadatum|

        end
      end
    end
  end
end
