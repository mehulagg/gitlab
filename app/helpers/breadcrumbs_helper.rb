# frozen_string_literal: true

module BreadcrumbsHelper
  def add_to_breadcrumbs(text, link)
    @breadcrumbs_extra_links ||= []
    @breadcrumbs_extra_links.push({
      text: text,
      link: link
    })
  end

  def breadcrumb_title_link
    return @breadcrumb_link if @breadcrumb_link

    "#{request.base_url}#{request.path}"
  end

  def breadcrumb_title(title)
    return if defined?(@breadcrumb_title)

    @breadcrumb_title = title
  end

  def breadcrumb_list_item(link)
    content_tag "li" do
      link + sprite_icon("angle-right", size: 8, css_class: "breadcrumbs-list-angle")
    end
  end

  def add_to_breadcrumb_dropdown(link, location: :before)
    @breadcrumb_dropdown_links ||= {}
    @breadcrumb_dropdown_links[location] ||= []
    @breadcrumb_dropdown_links[location] << link
  end

  def push_to_schema_breadcrumb(text, link)
    @push_schema_breadcrumb ||= []
    @push_schema_breadcrumb.push(schema_list_item(text, link, @push_schema_breadcrumb.size + 1))
  end

  def schema_breadcrumb_json
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': @push_schema_breadcrumb
    }.to_json
  end

  private

  def schema_list_item(text, link, position)
    {
      '@type' => 'ListItem',
      'position' => position,
      'item' => {
        '@id' => link,
        'name' => text
      }
    }
  end
end
