<script>
import { GlButton } from '@gitlab/ui';
import createFlash, { FLASH_TYPES } from '~/flash';
import { __, s__ } from '~/locale';
import runnersRegistrationTokenReset from '~/runner/graphql/runners_registration_token_reset.mutation.graphql';

export default {
  components: {
    GlButton,
  },
  data() {
    return {
      loading: false,
    };
  },
  computed: {},
  methods: {
    async resetToken() {
      // TODO Replace confirmation with gl-modal
      // eslint-disable-next-line no-alert
      if (!window.confirm(s__('Runners|Are you sure you want to delete this runner?'))) {
        return;
      }

      this.loading = true;
      try {
        const {
          data: {
            runnersRegistrationTokenReset: { token, errors },
          },
        } = await this.$apollo.mutate({
          mutation: runnersRegistrationTokenReset,
          variables: {
            input: {},
          },
        });
        if (errors && errors.length) {
          this.onError(new Error(errors[0]));
          return;
        }
        this.onSuccess(token);
      } catch (e) {
        this.onError(e);
      } finally {
        this.loading = false;
      }
    },
    onError(error) {
      const { message } = error;
      createFlash({ message });
    },
    onSuccess(token) {
      createFlash({
        message: __('New runners registration token has been generated!'),
        type: FLASH_TYPES.SUCCESS,
      });
      this.$emit('tokenReset', token);
    },
  },
};
</script>
<template>
  <gl-button :loading="loading" @click="resetToken">
    {{ __('Reset registration token') }}
  </gl-button>
</template>
