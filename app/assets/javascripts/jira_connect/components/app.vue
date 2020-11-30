<script>
export default {
  name: 'JiraConnectApp',
  props: {
    isGitlabConnected: {
      type: String,
      required: true,
    },
    jiraConnectUsersPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <h1>GitLab for Jira Configuration</h1>

    <template v-if="!isGitlabConnected">
      <h2 class="heading-with-border">Sign in to GitLab.com to get started.</h2>

      <div class="gl-mt-5">
        <a
          :href="jiraConnectUsersPath"
          target="_blank"
          class="ak-button ak-button__appearance-primary js-jira-connect-sign-in"
        >
          Sign in to GitLab
        </a>
      </div>

      <div class="gl-mt-5">
        <p>Note: this integration only works with accounts on GitLab.com (SaaS).</p>
      </div>
    </template>
  </div>
</template>
