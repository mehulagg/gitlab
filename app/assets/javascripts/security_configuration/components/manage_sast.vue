<script>
import { GlButton } from '@gitlab/ui';
import configureSastMutation from '~/security_configuration/graphql/configure_sast.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

export default {
  components: {
    GlButton,
  },
  inject: {
    projectPath: {
      from: 'projectPath',
      default: '',
    },
  },
  data: () => ({
    isLoading: false,
  }),
  methods: {
    async mutate() {
      console.log('mutate2');
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

        if (errors.length > 0) {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          throw new Error(errors[0]);
        }

        if (!successPath) {          
          throw new Error(__('SAST merge request creation mutation failed'));
        }

        redirectTo(successPath);
      } catch (e) {
        this.$emit('error', e.message);
        this.isLoading = false;
      }
    },
  },
};
</script>

<template>
  <gl-button :loading="isLoading" variant="success" category="secondary" @click="mutate"
    >{{ __("Configure via Merge Request") }}</gl-button
  >
</template>
