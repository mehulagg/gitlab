<script>
import { GlSprintf, GlLink } from '@gitlab/ui';
import EventItem from 'ee/vue_shared/security_reports/components/event_item.vue';
import { __ } from '~/locale';

export default {
  components: {
    EventItem,
    GlSprintf,
    GlLink,
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
    hasProjectUrl() {
      return Boolean(this.project?.value && this.project?.url);
    },
    eventText() {
      if (this.hasProjectUrl) {
        return __('Created issue %{issueLink} at %{projectLink}');
      }

      return __('Created issue %{issueLink}');
    },
  },
};
</script>

<template>
  <event-item :author="feedback.author" :created-at="feedback.created_at" icon-name="issues">
    <gl-sprintf :message="eventText">
      <template #issueLink>
        <gl-link :href="feedback.issue_url">#{{ feedback.issue_iid }}</gl-link>
      </template>
      <template v-if="hasProjectUrl" #projectLink>
        <gl-link :href="project.url">{{ project.value }}</gl-link>
      </template>
    </gl-sprintf>
  </event-item>
</template>
