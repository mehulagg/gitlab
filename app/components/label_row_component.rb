# frozen_string_literal: true

class LabelRowComponent < ApplicationComponent # rubocop:disable Gitlab/NamespacedClass
  def initialize(subject: nil, label:, force_priority: false)
    @subject = subject
    @label = label
    @force_priority = force_priority
  end

  private

  def show_label_issues_link?
    return false if no_subject?

    helpers.show_label_issuables_link?(@label, :issues)
  end

  def show_label_merge_requests_link?
    return false if no_subject?

    helpers.show_label_issuables_link?(@label, :merge_requests)
  end

  def show_labels_full_path?
    return false if no_subject?

    if @subject.respond_to?(:subgroup?)
      @subject.subgroup?
    else
      true
    end
  end

  def no_subject?
    @subject.nil?
  end
end
