# frozen_string_literal: true

# rubocop:disable Rails/ActiveRecordAliases
class WikiPage
  PageChangedError = Class.new(StandardError)
  PageRenameError = Class.new(StandardError)
  PageNotFoundError = Class.new(StandardError)
  FrontMatterTooLong = Class.new(StandardError)

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include StaticModel
  extend ActiveModel::Naming

  delegate :content, :front_matter, to: :parsed_content

  def self.primary_key
    'slug'
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, 'wiki')
  end

  def eql?(other)
    return false unless other.present? && other.is_a?(self.class)

    slug == other.slug && wiki.container == other.wiki.container
  end

  alias_method :==, :eql?

  # Sorts and groups pages by directory.
  #
  # pages - an array of WikiPage objects.
  #
  # Returns an array of WikiPage and WikiDirectory objects. The entries are
  # sorted by alphabetical order (directories and pages inside each directory).
  # Pages at the root level come before everything.
  def self.group_by_directory(pages)
    return [] if pages.blank?

    pages.each_with_object([]) do |page, grouped_pages|
      next grouped_pages << page unless page.directory.present?

      directory = grouped_pages.find do |obj|
        obj.is_a?(WikiDirectory) && obj.slug == page.directory
      end

      next directory.pages << page if directory

      grouped_pages << WikiDirectory.new(page.directory, [page])
    end
  end

  def self.unhyphenize(name)
    name.gsub(/-+/, ' ')
  end

  def to_key
    [:slug]
  end

  validates :title, presence: true
  validates :content, presence: true
  validate :validate_path_limits, if: :title_changed?

  # The GitLab Wiki instance.
  attr_reader :wiki
  delegate :container, to: :wiki

  # The raw Gitlab::Git::WikiPage instance.
  attr_reader :page

  # The attributes Hash used for storing and validating
  # new Page values before writing to the raw repository.
  attr_accessor :attributes

  def hook_attrs
    Gitlab::HookData::WikiPageBuilder.new(self).build
  end

  # Construct a new WikiPage
  #
  # @param [Wiki] wiki
  # @param [Gitlab::Git::WikiPage] page
  def initialize(wiki, page = nil)
    @wiki       = wiki
    @page       = page
    @attributes = {}.with_indifferent_access
  end

  # The escaped URL path of this page.
  def slug
    attributes[:slug] ||= page&.url_path.presence || wiki.wiki.preview_slug(title, format)
  end

  alias_method :to_param, :slug

  def human_title
    return 'Home' if title == Wiki::HOMEPAGE

    title
  end

  # The formatted title of this page.
  def title
    attributes[:title] ||= page&.title || ''
  end

  # Sets the title of this page.
  def title=(new_title)
    attributes[:title] = new_title
  end

  def raw_content
    attributes[:content] ||= page&.text_data
  end

  # The hierarchy of the directory this page is contained in.
  def directory
    wiki.page_title_and_dir(slug)&.last.to_s
  end

  # The markup format for the page.
  def format
    attributes[:format] ||= page&.format || :markdown
  end

  # The commit message for this page version.
  def message
    version.try(:message)
  end

  # The GitLab Commit instance for this page.
  def version
    return unless persisted?

    attributes[:version] ||= page.version
  end

  def path
    return unless persisted?

    attributes[:path] ||= page.path
  end

  def versions(options = {})
    return [] unless persisted?

    wiki.wiki.page_versions(page.path, options)
  end

  def count_versions
    return [] unless persisted?

    wiki.wiki.count_page_versions(page.path)
  end

  def last_version
    attributes[:last_version] ||= versions(limit: 1).first
  end

  def last_commit_sha
    last_version&.sha
  end

  # Returns boolean True or False if this instance
  # is an old version of the page.
  def historical?
    return false unless last_commit_sha && version

    page.historical? && last_commit_sha != version.sha
  end

  # Returns boolean True or False if this instance
  # is the latest commit version of the page.
  def latest?
    !historical?
  end

  # Returns boolean True or False if this instance
  # has been fully created on disk or not.
  def persisted?
    page.present?
  end

  def reload
    raise PageNotFoundError unless page

    load_page(page.title)
    self
  end

  # Creates a new Wiki Page.
  #
  # attr - Hash of attributes to set on the new page.
  #       :title   - The title (optionally including dir) for the new page.
  #       :content - The raw markup content.
  #       :format  - Optional symbol representing the
  #                  content format. Can be any type
  #                  listed in the Wiki::MARKUPS
  #                  Hash.
  #       :message - Optional commit message to set on
  #                  the new page.
  #
  # Returns the String SHA1 of the newly created page
  # or False if the save was unsuccessful.
  def create(attrs = {})
    update_attributes(attrs)

    save do
      wiki.create_page(title, content, format, attrs[:message])
    end
  end

  # Updates an existing Wiki Page, creating a new version.
  #
  # attrs - Hash of attributes to be updated on the page.
  #        :content         - The raw markup content to replace the existing.
  #        :format          - Optional symbol representing the content format.
  #                           See Wiki::MARKUPS Hash for available formats.
  #        :message         - Optional commit message to set on the new version.
  #        :last_commit_sha - Optional last commit sha to validate the page unchanged.
  #        :title           - The Title (optionally including dir) to replace existing title
  #
  # Returns the String SHA1 of the newly created page
  # or False if the save was unsuccessful.
  def update(attrs = {})
    last_commit_sha = attrs.delete(:last_commit_sha)

    if last_commit_sha && last_commit_sha != self.last_commit_sha
      raise PageChangedError
    end

    update_attributes(attrs)

    if title.present? && title_changed? && wiki.find_page(title).present?
      attributes[:title] = page.title
      raise PageRenameError
    end

    save do
      wiki.update_page(
        page,
        content: raw_content,
        format: format,
        message: attrs[:message],
        title: title
      )
    end
  end

  # Destroys the Wiki Page.
  #
  # Returns boolean True or False.
  def delete
    if wiki.delete_page(page)
      true
    else
      false
    end
  end

  # Relative path to the partial to be used when rendering collections
  # of this object.
  def to_partial_path
    # TODO: Move into shared/ with https://gitlab.com/gitlab-org/gitlab/-/issues/196054
    'projects/wikis/wiki_page'
  end

  def id
    page.version.to_s
  end

  def title_changed?
    if persisted?
      old_title, old_dir = wiki.page_title_and_dir(self.class.unhyphenize(page.url_path))
      new_title, new_dir = wiki.page_title_and_dir(self.class.unhyphenize(title))

      new_title != old_title || (title.include?('/') && new_dir != old_dir)
    else
      title.present?
    end
  end

  # Updates the current @attributes hash by merging a hash of params
  def update_attributes(attrs)
    attrs[:title] = process_title(attrs[:title]) if attrs[:title].present?
    update_front_matter(attrs)

    attrs.slice!(:content, :format, :message, :title)

    attributes.delete(:parsed_content) if attrs.has_key?(:content)
    attributes.merge!(attrs)
  end

  def to_ability_name
    'wiki_page'
  end

  private

  def load_page(title)
    attributes.clear
    @page = wiki.find_page(title)&.page

    raise PageNotFoundError unless page
  end

  def serialize_front_matter(hash)
    return '' unless hash.present?

    YAML.dump(hash.transform_keys(&:to_s)) + "---\n"
  end

  def update_front_matter(attrs)
    return unless Gitlab::WikiPages::FrontMatterParser.enabled?(container)
    return unless attrs.has_key?(:front_matter)

    fm_yaml = serialize_front_matter(attrs[:front_matter])
    raise FrontMatterTooLong if fm_yaml.size > Gitlab::WikiPages::FrontMatterParser::MAX_FRONT_MATTER_LENGTH

    attrs[:content] = fm_yaml + (attrs[:content].presence || content)
  end

  def parsed_content
    attributes[:parsed_content] ||=
      Gitlab::WikiPages::FrontMatterParser.new(raw_content, container).parse
  end

  # Process and format the title based on the user input.
  def process_title(title)
    return if title.blank?

    title = deep_title_squish(title)
    current_dirname = File.dirname(title)

    if persisted?
      return title[1..-1] if current_dirname == '/'
      return File.join([directory.presence, title].compact) if current_dirname == '.'
    end

    title
  end

  # This method squishes all the filename
  # i.e: '   foo   /  bar  / page_name' => 'foo/bar/page_name'
  def deep_title_squish(title)
    components = title.split(File::SEPARATOR).map(&:squish)

    File.join(components)
  end

  def save
    return false unless valid?

    unless yield
      errors.add(:base, wiki.error_message)
      return false
    end

    load_page(title)
    true
  end

  def validate_path_limits
    return unless title.present?

    *dirnames, filename = title.split('/')

    if filename && filename.bytesize > Gitlab::WikiPages::MAX_TITLE_BYTES
      errors.add(:title, _("exceeds the limit of %{bytes} bytes") % {
        bytes: Gitlab::WikiPages::MAX_TITLE_BYTES
      })
    end

    invalid_dirnames = dirnames.select { |d| d.bytesize > Gitlab::WikiPages::MAX_DIRECTORY_BYTES }
    invalid_dirnames.each do |dirname|
      errors.add(:title, _('exceeds the limit of %{bytes} bytes for directory name "%{dirname}"') % {
        bytes: Gitlab::WikiPages::MAX_DIRECTORY_BYTES,
        dirname: dirname
      })
    end
  end
end
