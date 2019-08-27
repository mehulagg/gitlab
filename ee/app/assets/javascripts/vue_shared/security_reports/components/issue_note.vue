<script>
import _ from 'lodash-es';
import { __, sprintf } from '~/locale';
import EventItem from 'ee/vue_shared/security_reports/components/event_item.vue';

export default {
  components: {
    EventItem,
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
  },
  computed: {
    eventText() {
      const { project, feedback } = this;
      const issueLink = `<a href="${feedback.issue_url}">#${feedback.issue_iid}</a>`;

      if (project && project.value && project.url) {
        const projectLink = `<a href="${_.escape(project.url)}">${_.escape(project.value)}</a>`;

        return sprintf(
          __('Created issue %{issueLink} at %{projectLink}'),
          {
            issueLink,
            projectLink,
          },
          false,
        );
      }
      return sprintf(__('Created issue %{issueLink}'), { issueLink }, false);
    },
  },
};
</script>

<template>
  <event-item :author="feedback.author" :created-at="feedback.created_at" icon-name="issue-created">
    <div v-html="eventText"></div>
  </event-item>
</template>
