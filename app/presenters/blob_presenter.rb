# frozen_string_literal: true

class BlobPresenter < Gitlab::View::Presenter::Delegated
  presents :blob

  def highlight(to: nil, plain: nil)
    load_all_blob_data

    Gitlab::Highlight.highlight(
      blob.path,
      limited_blob_data(to: to),
      language: language,
      plain: plain
    )
  end

  def web_url
    url_helpers.project_blob_url(project, ref_qualified_path)
  end

  def web_path
    url_helpers.project_blob_path(project, ref_qualified_path)
  end

  def edit_blob_path
    url_helpers.project_edit_blob_path(project, ref_qualified_path)
  end

  def raw_path
    url_helpers.project_raw_path(project, ref_qualified_path)
  end

  def replace_path
    url_helpers.project_create_blob_path(project, ref_qualified_path)
  end

  private

  def url_helpers
    Gitlab::Routing.url_helpers
  end

  def project
    blob.repository.project
  end

  def ref_qualified_path
    File.join(blob.commit_id, blob.path)
  end

  def load_all_blob_data
    blob.load_all_data! if blob.respond_to?(:load_all_data!)
  end

  def limited_blob_data(to: nil)
    return blob.data if to.blank?

    # Even though we don't need all the lines at the start of the file (e.g
    # viewing the middle part of a file), they still need to be highlighted
    # to ensure that the succeeding lines can be formatted correctly (e.g.
    # multi-line comments).
    all_lines[0..to - 1].join
  end

  def all_lines
    @all_lines ||= blob.data.lines
  end

  def language
    blob.language_from_gitattributes
  end
end
