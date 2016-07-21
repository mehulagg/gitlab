# MarkdownMatchers
#
# Custom matchers for our custom HTML::Pipeline filters. These are used to test
# that specific filters are or are not used by our defined pipelines.
#
# Must be included manually.
module MarkdownMatchers
  extend RSpec::Matchers::DSL
  include Capybara::Node::Matchers

  # RelativeLinkFilter
  matcher :parse_relative_links do
    set_default_markdown_messages

    match do |actual|
      link = actual.at_css('a:contains("Relative Link")')
      image = actual.at_css('img[alt="Relative Image"]')

      expect(link['href']).to end_with('master/doc/README.md')
      expect(image['src']).to end_with('master/app/assets/images/touch-icon-ipad.png')
    end
  end

  # EmojiFilter
  matcher :parse_emoji do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('img.emoji', count: 10)

      image = actual.at_css('img.emoji')
      expect(image['src'].to_s).to start_with(Gitlab.config.gitlab.url + '/assets')
    end
  end

  # TableOfContentsFilter
  matcher :create_header_links do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('h1 a#gitlab-markdown')
      expect(actual).to have_selector('h2 a#markdown')
      expect(actual).to have_selector('h3 a#autolinkfilter')
    end
  end

  # AutolinkFilter
  matcher :create_autolinks do
    def have_autolink(link)
      have_link(link, href: link)
    end

    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_autolink('http://about.gitlab.com/')
      expect(actual).to have_autolink('https://google.com/')
      expect(actual).to have_autolink('ftp://ftp.us.debian.org/debian/')
      expect(actual).to have_autolink('smb://foo/bar/baz')
      expect(actual).to have_autolink('irc://irc.freenode.net/git')
      expect(actual).to have_autolink('http://localhost:3000')

      %w(code a kbd).each do |elem|
        expect(body).not_to have_selector("#{elem} a")
      end
    end
  end

  # GollumTagsFilter
  matcher :parse_gollum_tags do
    def have_image(src)
      have_css("img[src$='#{src}']")
    end

    prefix = '/namespace1/gitlabhq/wikis'
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_link('linked-resource', href: "#{prefix}/linked-resource")
      expect(actual).to have_link('link-text', href: "#{prefix}/linked-resource")
      expect(actual).to have_link('http://example.com', href: 'http://example.com')
      expect(actual).to have_link('link-text', href: 'http://example.com/pdfs/gollum.pdf')
      expect(actual).to have_image("#{prefix}/images/example.jpg")
      expect(actual).to have_image('http://example.com/images/example.jpg')
    end
  end

  # UserReferenceFilter
  matcher :reference_users do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-project_member', count: 4)
    end
  end

  # IssueReferenceFilter
  matcher :reference_issues do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-issue', count: 6)
    end
  end

  # MergeRequestReferenceFilter
  matcher :reference_merge_requests do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-merge_request', count: 6)
      expect(actual).to have_selector('em a.gfm-merge_request')
    end
  end

  # SnippetReferenceFilter
  matcher :reference_snippets do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-snippet', count: 5)
    end
  end

  # CommitRangeReferenceFilter
  matcher :reference_commit_ranges do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-commit_range', count: 5)
    end
  end

  # CommitReferenceFilter
  matcher :reference_commits do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-commit', count: 5)
    end
  end

  # LabelReferenceFilter
  matcher :reference_labels do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-label', count: 4)
    end
  end

  # MilestoneReferenceFilter
  matcher :reference_milestones do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('a.gfm.gfm-milestone', count: 6)
    end
  end

  # TaskListFilter
  matcher :parse_task_lists do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('ul.task-list', count: 2)
      expect(actual).to have_selector('li.task-list-item', count: 7)
      expect(actual).to have_selector('input[checked]', count: 3)
    end
  end

  # InlineDiffFilter
  matcher :parse_inline_diffs do
    set_default_markdown_messages

    match do |actual|
      expect(actual).to have_selector('span.idiff.addition', count: 2)
      expect(actual).to have_selector('span.idiff.deletion', count: 2)
    end
  end

  # VideoLinkFilter
  matcher :parse_video_links do
    set_default_markdown_messages

    match do |actual|
      video = actual.at_css('video')

      expect(video['src']).to end_with('/assets/videos/gitlab-demo.mp4')
    end
  end
end

# Monkeypatch the matcher DSL so that we can reduce some noisy duplication for
# setting the failure messages for these matchers
module RSpec::Matchers::DSL::Macros
  def set_default_markdown_messages
    failure_message do
      # expected to parse emoji, but didn't
      "expected to #{description}, but didn't"
    end

    failure_message_when_negated do
      # expected not to parse task lists, but did
      "expected not to #{description}, but did"
    end
  end
end
