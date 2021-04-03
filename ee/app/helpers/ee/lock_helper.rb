# frozen_string_literal: true

module EE
  module LockHelper
    def lock_file_link(project = @project, path = @path, html_options: {})
      return unless project.feature_available?(:file_locks)
      return unless current_user

      path_lock = project.find_path_lock(path, downstream: true)

      if path_lock
        locker = path_lock.user.name

        if path_lock.exact?(path)
          exact_lock_file_link(path_lock, html_options, locker)
        elsif path_lock.upstream?(path)
          upstream_lock_file_link(path_lock, html_options, locker)
        elsif path_lock.downstream?(path)
          downstream_lock_file_link(path_lock, html_options, locker)
        end
      else
        _lock_link(current_user, project, html_options: html_options)
      end
    end

    def exact_lock_file_link(path_lock, html_options, locker)
      if can_unlock?(path_lock)
        html_options[:data] = { state: :unlock }
        tooltip = path_lock.user == current_user ? '' : "Locked by #{locker}"
        enabled_lock_link("Unlock", tooltip, html_options)
      else
        disabled_lock_link("Unlock", "Locked by #{locker}. You do not have permission to unlock this", html_options)
      end
    end

    def upstream_lock_file_link(path_lock, html_options, locker)
      additional_phrase = can_unlock?(path_lock) ? 'Unlock that directory in order to unlock this' : 'You do not have permission to unlock it'
      disabled_lock_link("Unlock", "#{locker} has a lock on \"#{path_lock.path}\". #{additional_phrase}", html_options)
    end

    def downstream_lock_file_link(path_lock, html_options, locker)
      additional_phrase = can_unlock?(path_lock) ? 'Unlock this in order to proceed' : 'You do not have permission to unlock it'
      disabled_lock_link("Lock", "This directory cannot be locked while #{locker} has a lock on \"#{path_lock.path}\". #{additional_phrase}", html_options)
    end

    def _lock_link(user, project, html_options: {})
      if can?(current_user, :push_code, project)
        html_options[:data] = { state: :lock }
        enabled_lock_link("Lock", '', html_options)
      else
        disabled_lock_link("Lock", "You do not have permission to lock this", html_options)
      end
    end

    def disabled_lock_link(label, title, html_options)
      html_options[:class] = "#{html_options[:class]} disabled"
      html_options['data-qa-selector'] = 'disabled_lock_button'

      # Disabled buttons with tooltips should have the tooltip attached
      # to a wrapper element https://bootstrap-vue.org/docs/components/tooltip#disabled-elements
      content_tag(:span, content_tag(:span, label, html_options), title: title, class: 'btn-group has-tooltip')
    end

    def enabled_lock_link(label, title, html_options)
      html_options['data-toggle'] = 'tooltip'
      html_options[:title] = title
      html_options[:class] = "#{html_options[:class]} has-tooltip"
      html_options['data-qa-selector'] = 'lock_button'

      link_to label, '#', html_options
    end
  end
end
