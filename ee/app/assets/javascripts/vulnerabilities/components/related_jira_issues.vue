<script>
import axios from 'axios';
import { GlButton, GlCard, GlIcon, GlLink, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import jiraLogo from '@gitlab/svgs/dist/illustrations/logos/jira.svg';

export default {
  components: {
    GlButton,
    GlCard,
    GlIcon,
    GlLink,
    jiraLogo,
  },
  directives: {
    SafeHtml,
  },
  props: {
    url: {
      type: String,
      required: true,
    },
    helpPath: {
      type: String,
      required: false,
    },
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      jiraLogo,
      isFetching: false,
      issues: [],
    };
  },
  mounted() {
    this.fetchIssues();
  },
  computed: {
    issuesCount() {
      return this.isFetching && !this.issues.length ? '...' : this.issues.length;
    },
  },
  methods: {
    async fetchIssues() {
      this.isFetching = true;
      // @TODO: error handling
      const { data } = await axios.get(this.endpoint);
      this.issues = data;
      this.isFetching = false;
    },
  },
};
</script>
<template>
  <gl-card body-class="gl-bg-gray-10" header-class="gl-py-3 gl-display-flex gl-align-items-center">
    <template #header>
      <h3 class="h5 gl-m-0">{{ __('Related Jira issues') }}</h3>
      <gl-link
        v-if="helpPath"
        :href="helpPath"
        target="_blank"
        class="gl-display-flex gl-align-items-center gl-ml-2 gl-mr-4 gl-text-gray-500"
        :aria-label="__('Read more about related issues')"
      >
        <gl-icon name="question" :size="12" role="text" />
      </gl-link>
      <span class="gl-display-inline-flex gl-align-items-center">
        <gl-icon name="issues" class="gl-mr-2 gl-text-gray-500" />
        {{ issuesCount }}
      </span>
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
          <gl-link :href="issue.web_url" target="_blank">
            <span v-safe-html="jiraLogo" class="svg-container jira-logo-container"></span>
            {{ issue.title }}
          </gl-link>
        </div>
      </gl-card>
    </ul>
  </gl-card>
</template>
