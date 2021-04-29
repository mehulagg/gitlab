<script>
import { GlButton } from '@gitlab/ui';
import vulnerabilityExternalIssueLinkCreate from 'ee/vue_shared/security_reports/graphql/vulnerabilityExternalIssueLinkCreate.mutation.graphql';
import { s__ } from '~/locale';

export const i18n = {
  createNewIssueLinkText: s__('VulnerabilityManagement|Create Jira issue'),
};

export default {
  i18n,
  components: {
    GlButton,
  },
  props: {
    vulnerabilityID: {
      type: Number,
      required: true,
    },
    variant: {
      type: String,
      required: false,
      default: 'success',
    },
  },
  data() {
    return {
      isLoading: false,
    };
  },
  methods: {
    async createJiraIssue() {
      this.isLoading = true;
      try {
        const { data } = await this.$apollo.mutate({
          mutation: vulnerabilityExternalIssueLinkCreate,
          variables: {
            input: {
              externalTracker: 'JIRA',
              linkType: 'CREATED',
              id: `gid://gitlab/Vulnerability/${this.vulnerabilityID}`,
            },
          },
        });
        const { errors } = data.vulnerabilityExternalIssueLinkCreate;

        if (errors.length > 0) {
          throw new Error(errors[0]);
        }

        this.isLoading = false;
        this.$emit('mutated');
      } catch (e) {
        this.$emit('createJiraIssueError', e.message);
        this.isLoading = false;
      }
    },
  },
};
</script>

<template>
  <gl-button
    :variant="variant"
    category="secondary"
    :loading="isLoading"
    icon="external-link"
    target="_blank"
    class="gl-ml-auto"
    data-testid="create-new-jira-issue"
    @click="createJiraIssue"
  >
    {{ $options.i18n.createNewIssueLinkText }}
  </gl-button>
</template>
