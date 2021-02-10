<script>
import { GlModal, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';

export default {
  components: { GlModal, GlFormGroup, GlFormInput },
  props: {
    newDirPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      directoryName: '',
    };
  },
  methods: {
    handleSubmit() {
      axios.post(this.newDirPath);
    },
  },
  i18n: {
    directoryNameLabel: __('Directory name'),
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    :ok-title="__('Create directory')"
    modal-id="new-directory"
    :title="__('Create New Directory')"
  >
    <form @submit.prevent>
      <gl-form-group label-for="directoryName" :label="$options.i18n.directoryNameLabel">
        <gl-form-input id="directoryName" v-model="directoryName" required />
      </gl-form-group>
    </form>
    <!-- 
          - project = @project.present(current_user: current_user)
          - branch_name = selected_branch

          .form-group.row.commit_message-group
            - nonce = SecureRandom.hex
            - descriptions = local_assigns.slice(:message_with_description, :message_without_description)
            = label_tag "commit_message-#{nonce}", class: 'col-form-label col-sm-2' do
              #{ _('Commit message') }
            .col-sm-10
              .commit-message-container
                .max-width-marker
                = text_area_tag 'commit_message',
                    (params[:commit_message] || local_assigns[:text] || local_assigns[:placeholder]),
                    class: 'form-control gl-form-input js-commit-message', placeholder: local_assigns[:placeholder],
                    data: descriptions,
                    required: true, rows: (local_assigns[:rows] || 3),
                    id: "commit_message-#{nonce}"
              - if local_assigns[:hint]
                %p.hint
                  = _('Try to keep the first line under 52 characters and the others under 72.')
              - if descriptions.present?
                .hint.js-with-description-hint
                  = link_to "#", class: "js-with-description-link" do
                    = _('Include description in commit message')
                .hint.js-without-description-hint.hide
                  = link_to "#", class: "js-without-description-link" do
                    = _("Don't include description in commit message")

          - if @project.empty_repo?
            = hidden_field_tag 'branch_name', @ref
          - else
            - if can?(current_user, :push_code, @project)
              .form-group.row.branch
                = label_tag 'branch_name', _('Target Branch'), class: 'col-form-label col-sm-2'
                .col-sm-10
                  = text_field_tag 'branch_name', branch_name, required: true, class: "form-control gl-form-input js-branch-name ref-name"

                  .js-create-merge-request-container
                    .form-check.gl-mt-3
                      - nonce = SecureRandom.hex
                      = check_box_tag 'create_merge_request', 1, true, class: 'js-create-merge-request form-check-input', id: "create_merge_request-#{nonce}"
                      = label_tag "create_merge_request-#{nonce}", class: 'form-check-label' do
                        - translation_variables = { new_merge_request: "<strong>#{_('new merge request')}</strong>" }
                        - translation = _('Start a %{new_merge_request} with these changes') % translation_variables
                        #{ translation.html_safe }

            - elsif project.can_current_user_push_to_branch?(branch_name)
              = hidden_field_tag 'branch_name', branch_name
            - else
              = hidden_field_tag 'branch_name', branch_name
              = hidden_field_tag 'create_merge_request', 1

            = hidden_field_tag 'original_branch', @ref, class: 'js-original-branch'

          .form-actions
            = submit_tag _("Create directory"), class: 'btn gl-button btn-success'
            = link_to "Cancel", '#', class: "btn gl-button btn-cancel", "data-dismiss" => "modal"

            - unless can?(current_user, :push_code, @project)
              .inline.gl-ml-3
                - if @project.branch_allows_collaboration?(current_user, selected_branch)
                  = commit_in_single_accessible_branch
                - else
                  = commit_in_fork_help
-->
    <div></div>
  </gl-modal>
</template>
