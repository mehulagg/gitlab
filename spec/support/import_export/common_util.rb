# frozen_string_literal: true

module ImportExport
  module CommonUtil
    def setup_symlink(tmpdir, symlink_name)
      allow_next_instance_of(Gitlab::ImportExport) do |instance|
        allow(instance).to receive(:storage_path).and_return(tmpdir)
      end

      File.open("#{tmpdir}/test", 'w') { |file| file.write("test") }
      FileUtils.ln_s("#{tmpdir}/test", "#{tmpdir}/#{symlink_name}")
    end

    def setup_import_export_config(name, prefix = nil)
      export_path = [prefix, 'spec', 'fixtures', 'lib', 'gitlab', 'import_export', name].compact
      export_path = File.join(*export_path)

      allow_any_instance_of(Gitlab::ImportExport).to receive(:export_path) { export_path }
    end

    def fixtures_path
      "spec/fixtures/lib/gitlab/import_export"
    end

    def test_tmp_path
      "tmp/tests/gitlab-test/import_export"
    end

    def ndjson_relations(dir_path, key)
      path = File.join(dir_path, "#{key}.ndjson")
      return unless File.exist?(path)

      relations = []

      File.foreach(path) do |line|
        json = ActiveSupport::JSON.decode(line)

        relations << json
      end

      relations.flatten
    end

    def project_json(filename)
      ::JSON.parse(IO.read(filename))
    end

    def restore_then_save_project(project, import_path:, export_path:)
      project_restorer = get_project_restorer(project, import_path)
      project_saver = get_project_saver(project, export_path)

      project_restorer.restore && project_saver.save
    end

    def get_project_restorer(project, import_path)
      Gitlab::ImportExport::Project::TreeRestorer.new(
        user: project.creator, shared: get_shared_env(path: import_path), project: project
      )
    end

    def get_project_saver(project, export_path)
      Gitlab::ImportExport::Project::TreeSaver.new(
        project: project, current_user: project.creator, shared: get_shared_env(path: export_path)
      )
    end

    def get_shared_env(path:)
      instance_double(Gitlab::ImportExport::Shared).tap do |shared|
        allow(shared).to receive(:export_path).and_return(path)
      end
    end
  end
end
