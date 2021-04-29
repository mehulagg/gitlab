# frozen_string_literal: true

module InProductMarketingHelper
  def inline_image_link(image, options)
    attachments.inline[image] = File.read(Rails.root.join("app/assets/images", image))
    image_tag attachments[image].url, **options
  end

  def about_link(image, width)
    link_to inline_image_link(image, { width: width, style: "width: #{width}px;", alt: s_('InProductMarketing|go to about.gitlab.com') }), 'https://about.gitlab.com/'
  end

  def footer_links(format: nil)
    links = [
      [s_('InProductMarketing|Blog'), 'https://about.gitlab.com/blog'],
      [s_('InProductMarketing|Twitter'), 'https://twitter.com/gitlab'],
      [s_('InProductMarketing|Facebook'), 'https://www.facebook.com/gitlab'],
      [s_('InProductMarketing|YouTube'), 'https://www.youtube.com/channel/UCnMGQ8QHMAnVIsI3xJrihhg']
    ]
    case format
    when :html
      links.map do |text, link|
        link_to(text, link)
      end
    else
      '| ' + links.map do |text, link|
        [text, link].join(' ')
      end.join("\n| ")
    end
  end

  def address(format: nil)
    s_('InProductMarketing|%{strong_start}GitLab Inc.%{strong_end} 268 Bush Street, #350, San Francisco, CA 94104, USA').html_safe % strong_options(format)
  end

  private

  def strong_options(format)
    case format
    when :html
      { strong_start: '<b>'.html_safe, strong_end: '</b>'.html_safe }
    else
      { strong_start: '', strong_end: '' }
    end
  end
end
