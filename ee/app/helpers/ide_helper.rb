module IdeHelper
  def show_new_ide?(project)
    cookies["new_repo"] == "true" && project.feature_available?(:ide)
  end

  def ide_edit_button(project = @project, ref = @ref, path = @path, options = {})
    return unless show_new_ide?(project)
    return unless blob = readable_blob(options, path, project, ref)

    common_classes = "btn js-edit-ide #{options[:extra_class]}"

    edit_button_tag(blob,
                    common_classes,
                    _('Web IDE'),
                    ide_edit_path(project, ref, path, options),
                    project,
                    ref)
  end
end
