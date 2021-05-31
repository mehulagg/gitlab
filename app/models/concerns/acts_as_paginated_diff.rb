# frozen_string_literal: true

module ActsAsPaginatedDiff
  def diffs_in_batch(batch_page, batch_size, diff_options:, modified_paths: nil)
    if modified_paths.present? && diff_options[:paths].empty?
      options = diff_options.merge(
        paths: paginated_paths(modified_paths, batch_page, batch_size),
        total_pages: modified_paths.count
      )

      diffs(options)
    else
      diffs(diff_options)
    end
  end

  def paginated_paths(paths, batch_page, batch_size)
    Kaminari.paginate_array(paths).page(batch_page).per(batch_size)
  end
end
