<script>
import { GlButton } from '@gitlab/ui';
import configureSastMutation from '~/security_configuration/graphql/configure_sast.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';
export default {
  inject: {
    projectPath: {
      from: 'projectPath',
      default: '',
    },
  },
  components: {
    GlButton,
  },
  data: () => ({
    isLoading: false,
  }),
  methods: {
    async mutate() {
      this.isLoading = true;
      try {
        const { data } = await this.$apollo.mutate({
          mutation: configureSastMutation,
          variables: {
            input: {
              projectPath: this.projectPath,
              configuration: { global: [], pipeline: [], analyzers: [] },
            },
          },
        });
        const { errors, successPath } = data.configureSast;

        if (errors.length > 0 || !successPath) {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          throw new Error('SAST merge request creation mutation failed');
        }
        redirectTo(successPath);
      } catch (e) {
        this.$emit('error', e.message);
        this.isLoading = false;
      }
      // do similar like app/assets/javascripts/security_configuration/sast/components/configuration_form.vue
    },
  },
};
</script>

<template>
  <gl-button :loading="isLoading" @click="mutate" variant="success" category="secondary"
    >Configure via Merge Request</gl-button
  >
</template>
