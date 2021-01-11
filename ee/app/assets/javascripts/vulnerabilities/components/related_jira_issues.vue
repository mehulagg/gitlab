<script>
import axios from 'axios';
import { GlCard, GlIcon, GlButton } from '@gitlab/ui';

export default {
  components: {
    GlCard,
    GlIcon,
    GlButton,
  },
  props: {
    url: {
      type: String,
      required: true,
    },
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      issues: [],
    };
  },
  mounted() {
    this.fetchIssues();
  },
  methods: {
    async fetchIssues() {
      // @TODO: error handling
      const { data } = await axios.get(this.endpoint);
      this.issues = data;
    },
  },
};
</script>
<template>
  <gl-card body-class="gl-bg-gray-10" header-class="gl-py-3 gl-display-flex gl-align-items-center">
    <template #header>
      <h3 class="h5 gl-m-0">{{ __('Related Jira issues') }}</h3>
      <gl-button
        variant="success"
        category="secondary"
        :href="url"
        target="__blank"
        class="gl-ml-auto"
        icon="external-link"
      >
        {{ __('Create new issue in Jira') }}
      </gl-button>
    </template>
    <ul class="gl-list-style-none gl-p-0 gl-m-0">
      <gl-card v-for="issue in issues" :key="issue.creted_at" tag="li" body-class="gl-py-3">
        <div class="gl-min-h-7 gl-display-flex gl-align-items-center">
          {{ issue.title }}
        </div>
      </gl-card>
    </ul>
  </gl-card>
</template>
