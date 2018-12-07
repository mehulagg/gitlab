# frozen_string_literal: true

module AuditEventsHelper
  def human_text(details)
    details.map { |key, value| select_keys(key, value) }.join(" ").humanize
  end

  def select_keys(key, value)
    if key =~ /^(author|target)_.*/
      ""
    else
      "#{key} <strong>#{value}</strong>"
    end
  end
end
