<script>
import { mapGetters, mapActions } from 'vuex';
import { GlToggle } from '@gitlab/ui';
import createFlash from '~/flash';
import { __ } from '~/locale';

export default {
  i18n: {
    header: {
      title: __('Notifications'),
      /* Any change to subscribeDisabledDescription
         must be reflected in app/helpers/notifications_helper.rb */
      subscribeDisabledDescription: __(
        'Notifications have been disabled by the project or group owner',
      ),
    },
    updateSubscribedErrorMessage: __('An error occurred while setting notifications status.'),
  },
  components: {
    GlToggle,
  },
  data() {
    return {
      loading: false,
    };
  },
  computed: {
    ...mapGetters({ getActiveIssue: 'getActiveIssue', projectPath: 'projectPathForActiveIssue' }),
    notificationText() {
      return this.getActiveIssue.emailsDisabled
        ? this.$options.i18n.header.subscribeDisabledDescription
        : this.$options.i18n.header.title;
    },
  },
  methods: {
    ...mapActions(['setActiveIssueNotification']),
    async handleToggle() {
      this.loading = true;

      try {
        await this.setActiveIssueNotification({
          subscribed: !this.getActiveIssue.subscribed,
          projectPath: this.projectPath,
        });
      } catch (error) {
        createFlash({ message: this.$options.i18n.updateSubscribedErrorMessage });
      } finally {
        this.subscribed = this.getActiveIssue.subscribed;
        this.loading = false;
      }
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center justify-content-between">
    <span data-testid="notification-header-text"> {{ notificationText }} </span>
    <gl-toggle
      v-if="!getActiveIssue.emailsDisabled"
      :is-loading="loading"
      :value="getActiveIssue.subscribed"
      data-testid="notification-subscribe-toggle"
      @change="handleToggle"
    />
  </div>
</template>
