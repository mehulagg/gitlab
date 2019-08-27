<script>
import _ from 'lodash-es';
import { __, sprintf } from '~/locale';
import EventItem from 'ee/vue_shared/security_reports/components/event_item.vue';
import { GlButton } from '@gitlab/ui';
import LoadingButton from '~/vue_shared/components/loading_button.vue';

export default {
  components: {
    EventItem,
    GlButton,
    LoadingButton,
  },
  props: {
    feedback: {
      type: Object,
      required: true,
    },
    project: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    isCommentingOnDismissal: {
      type: Boolean,
      required: false,
      default: false,
    },
    isShowingDeleteButtons: {
      type: Boolean,
      required: false,
      default: false,
    },
    showDismissalCommentActions: {
      type: Boolean,
      required: false,
      default: false,
    },
    isDismissingVulnerability: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    eventText() {
      const { project, feedback } = this;
      const { pipeline } = feedback;

      const pipelineLink =
        pipeline && pipeline.path && pipeline.id
          ? `<a href="${pipeline.path}">#${pipeline.id}</a>`
          : null;

      const projectLink =
        project && project.url && project.value
          ? `<a href="${_.escape(project.url)}">${_.escape(project.value)}</a>`
          : null;

      if (pipelineLink && projectLink) {
        return sprintf(
          __('Dismissed on pipeline %{pipelineLink} at %{projectLink}'),
          { pipelineLink, projectLink },
          false,
        );
      } else if (pipelineLink && !projectLink) {
        return sprintf(__('Dismissed on pipeline %{pipelineLink}'), { pipelineLink }, false);
      } else if (!pipelineLink && projectLink) {
        return sprintf(__('Dismissed at %{projectLink}'), { projectLink }, false);
      }
      return __('Dismissed');
    },
    commentDetails() {
      return this.feedback.comment_details;
    },
    vulnDismissalActionButtons() {
      return [
        {
          iconName: 'pencil',
          emit: 'editVulnerabilityDismissalComment',
          title: __('Edit Comment'),
        },
        {
          iconName: 'remove',
          emit: 'showDismissalDeleteButtons',
          title: __('Delete Comment'),
        },
      ];
    },
  },
};
</script>

<template>
  <div>
    <event-item
      :author="feedback.author"
      :created-at="feedback.created_at"
      icon-name="cancel"
      icon-style="ci-status-icon-pending"
    >
      <div v-html="eventText"></div>
    </event-item>
    <template v-if="commentDetails && !isCommentingOnDismissal">
      <hr class="my-3" />
      <event-item
        :action-buttons="vulnDismissalActionButtons"
        :author="commentDetails.comment_author"
        :created-at="commentDetails.comment_timestamp"
        :show-right-slot="isShowingDeleteButtons"
        :show-action-buttons="showDismissalCommentActions"
        icon-name="comment"
        icon-style="ci-status-icon-pending"
        @editVulnerabilityDismissalComment="$emit('editVulnerabilityDismissalComment')"
        @showDismissalDeleteButtons="$emit('showDismissalDeleteButtons')"
        @hideDismissalDeleteButtons="$emit('hideDismissalDeleteButtons')"
        @deleteDismissalComment="$emit('deleteDismissalComment')"
      >
        {{ commentDetails.comment }}

        <template v-slot:right-content>
          <div class="d-flex flex-grow-1 align-self-start flex-row-reverse">
            <loading-button
              :label="__('Delete comment')"
              container-class="btn btn-remove"
              @click="$emit('deleteDismissalComment')"
            />

            <gl-button class="mr-2" @click="$emit('hideDismissalDeleteButtons')">
              {{ __('Cancel') }}
            </gl-button>
          </div>
        </template>
      </event-item>
    </template>
  </div>
</template>
