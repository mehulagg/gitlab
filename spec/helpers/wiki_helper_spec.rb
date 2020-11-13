# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WikiHelper do
  let_it_be(:wiki) { build_stubbed(:project_wiki) }

  describe '#wiki_page_title' do
    let_it_be(:page) { create(:wiki_page) }

    it 'sets the title for the show action' do
      expect(helper).to receive(:breadcrumb_title).with(page.human_title)
      expect(helper).to receive(:wiki_breadcrumb_dropdown_links).with(page.slug)
      expect(helper).to receive(:page_title).with(page.human_title, 'Wiki')
      expect(helper).to receive(:add_to_breadcrumbs).with('Wiki', helper.wiki_path(page.wiki))

      helper.wiki_page_title(page)
    end

    it 'sets the title for a custom action' do
      expect(helper).to receive(:breadcrumb_title).with(page.human_title)
      expect(helper).to receive(:wiki_breadcrumb_dropdown_links).with(page.slug)
      expect(helper).to receive(:page_title).with('Edit', page.human_title, 'Wiki')
      expect(helper).to receive(:add_to_breadcrumbs).with('Wiki', helper.wiki_path(page.wiki))

      helper.wiki_page_title(page, 'Edit')
    end

    it 'sets the title for an unsaved page' do
      expect(page).to receive(:persisted?).and_return(false)
      expect(helper).not_to receive(:breadcrumb_title)
      expect(helper).not_to receive(:wiki_breadcrumb_dropdown_links)
      expect(helper).to receive(:page_title).with('Wiki')
      expect(helper).to receive(:add_to_breadcrumbs).with('Wiki', helper.wiki_path(page.wiki))

      helper.wiki_page_title(page)
    end
  end

  describe '#breadcrumb' do
    context 'when the page is at the root level' do
      it 'returns the capitalized page name' do
        slug = 'page-name'

        expect(helper.breadcrumb(slug)).to eq('Page name')
      end
    end

    context 'when the page is inside a directory' do
      it 'returns the capitalized name of each directory and of the page itself' do
        slug = 'dir_1/page-name'

        expect(helper.breadcrumb(slug)).to eq('Dir_1 / Page name')
      end
    end
  end

  describe '#wiki_attachment_upload_url' do
    before do
      @wiki = wiki
    end

    it 'returns the upload endpoint for project wikis' do
      expect(helper.wiki_attachment_upload_url).to end_with("/api/v4/projects/#{@wiki.project.id}/wikis/attachments")
    end

    it 'raises an exception for unsupported wiki containers' do
      allow(wiki).to receive(:container).and_return(User.new)

      expect do
        helper.wiki_attachment_upload_url
      end.to raise_error(TypeError)
    end
  end

  describe '#wiki_sort_controls' do
    let(:wiki) { create(:project_wiki) }
    let(:wiki_link) { helper.wiki_sort_controls(wiki, sort, direction) }
    let(:classes) { "btn btn-default has-tooltip reverse-sort-btn qa-reverse-sort rspec-reverse-sort" }

    def expected_link(sort, direction, icon_class)
      path = "/#{wiki.project.full_path}/-/wikis/pages?direction=#{direction}&sort=#{sort}"

      helper.link_to(path, type: 'button', class: classes, title: 'Sort direction') do
        helper.sprite_icon("sort-#{icon_class}")
      end
    end

    context 'initial call' do
      let(:sort) { nil }
      let(:direction) { nil }

      it 'renders with default values' do
        expect(wiki_link).to eq(expected_link('title', 'desc', 'lowest'))
      end
    end

    context 'sort by title' do
      let(:sort) { 'title' }
      let(:direction) { 'asc' }

      it 'renders a link with opposite direction' do
        expect(wiki_link).to eq(expected_link('title', 'desc', 'lowest'))
      end
    end

    context 'sort by created_at' do
      let(:sort) { 'created_at' }
      let(:direction) { 'desc' }

      it 'renders a link with opposite direction' do
        expect(wiki_link).to eq(expected_link('created_at', 'asc', 'highest'))
      end
    end
  end

  describe '#wiki_sort_title' do
    it 'returns a title corresponding to a key' do
      expect(helper.wiki_sort_title('created_at')).to eq('Created date')
      expect(helper.wiki_sort_title('title')).to eq('Title')
    end

    it 'defaults to Title if a key is unknown' do
      expect(helper.wiki_sort_title('unknown')).to eq('Title')
    end
  end

  describe '#wiki_page_tracking_context' do
    let_it_be(:page) { create(:wiki_page, title: 'path/to/page 💩', content: '💩', format: :markdown) }

    subject { helper.wiki_page_tracking_context(page) }

    it 'returns the tracking context' do
      expect(subject).to eq(
        'wiki-format'               => :markdown,
        'wiki-title-size'           => 9,
        'wiki-content-size'         => 4,
        'wiki-directory-nest-level' => 2,
        'wiki-container-type'       => 'Project'
      )
    end

    it 'returns a nest level of zero for toplevel files' do
      expect(page).to receive(:path).and_return('page')
      expect(subject).to include('wiki-directory-nest-level' => 0)
    end
  end

  describe '#wiki_http_clone_button' do
    let_it_be(:user) { create(:user) }
    let(:has_tooltip_class) { 'has-tooltip' }

    def element
      element = helper.wiki_http_clone_button(wiki)

      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'with internal auth enabled' do
      context 'when user has a password' do
        it 'shows no tooltip' do
          expect(element.attr('class')).not_to include(has_tooltip_class)
        end
      end

      context 'when user has password automatically set' do
        let_it_be(:user) { create(:user, password_automatically_set: true) }

        it 'shows the password text on the dropdown' do
          description = element.search('.dropdown-menu-inner-content').first

          expect(description.inner_text).to eq 'Set a password on your account to pull or push via HTTP.'
        end
      end
    end

    context 'with internal auth disabled' do
      before do
        stub_application_setting(password_authentication_enabled_for_git?: false)
      end

      context 'when user has no personal access tokens' do
        it 'has a personal access token text on the dropdown description' do
          description = element.search('.dropdown-menu-inner-content').first

          expect(description.inner_text).to eq 'Create a personal access token on your account to pull or push via HTTP.'
        end
      end

      context 'when user has personal access tokens' do
        before do
          create(:personal_access_token, user: user)
        end

        it 'does not have a personal access token text on the dropdown description' do
          description = element.search('.dropdown-menu-inner-content').first

          expect(description).to be_nil
        end
      end
    end

    context 'when user is ldap user' do
      let_it_be(:user) { create(:omniauth_user, password_automatically_set: true) }

      it 'shows no tooltip' do
        expect(element.attr('class')).not_to include(has_tooltip_class)
      end
    end
  end

  describe '#wiki_ssh_button' do
    let_it_be(:user) { create(:user) }

    def element
      element = helper.wiki_ssh_clone_button(wiki)

      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'without an ssh key on the user' do
      it 'shows a warning on the dropdown description' do
        description = element.search('.dropdown-menu-inner-content').first

        expect(description.inner_text).to eq "You won't be able to pull or push repositories via SSH until you add an SSH key to your profile"
      end
    end

    context 'without an ssh key on the user and user_show_add_ssh_key_message unset' do
      before do
        stub_application_setting(user_show_add_ssh_key_message: false)
      end

      it 'there is no warning on the dropdown description' do
        description = element.search('.dropdown-menu-inner-content').first

        expect(description).to be_nil
      end
    end

    context 'with an ssh key on the user' do
      before do
        create(:key, user: user)
      end

      it 'there is no warning on the dropdown description' do
        description = element.search('.dropdown-menu-inner-content').first

        expect(description).to eq nil
      end
    end
  end

  describe 'ssh and http clone buttons' do
    let_it_be(:user) { create(:user) }

    def http_button_element
      element = helper.wiki_http_clone_button(wiki, append_link: false)

      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    def ssh_button_element
      element = helper.wiki_ssh_clone_button(wiki, append_link: false)

      Nokogiri::HTML::DocumentFragment.parse(element).first_element_child
    end

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    it 'only shows the title of any of the clone buttons when append_link is false' do
      expect(http_button_element.text).to eq('HTTP')
      expect(http_button_element.search('.dropdown-menu-inner-content').first).to eq(nil)
      expect(ssh_button_element.text).to eq('SSH')
      expect(ssh_button_element.search('.dropdown-menu-inner-content').first).to eq(nil)
    end
  end
end
