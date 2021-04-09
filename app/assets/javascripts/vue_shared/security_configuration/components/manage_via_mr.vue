<script>
import { GlButton } from '@gitlab/ui';
import { redirectTo } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import apolloProvider from '../provider';

export default {
  apolloProvider,
  components: {
    GlButton,
  },
  props: {
    mutation: {
      type: Object,
      required: true,
    },
    mutationId: {
      type: String,
      required: true,
    },
    feature: {
      type: Object,
      required: false,
      default() {
        return {};
      },
    },
  },
  data() {
    return {
      isLoading: false,
    };
  },
  methods: {
    async mutate() {
      this.isLoading = true;
      try {
        const { data } = await this.$apollo.mutate(this.mutation);
        const { errors, successPath } = data[this.mutationId];

        if (errors.length > 0) {
          throw new Error(errors[0]);
        }

        if (!successPath) {
          throw new Error(
            s__(
              `SecurityConfiguration|${this.feature.name} merge request creation mutation failed`,
            ),
          );
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
  <gl-button
    v-if="!feature.configured"
    :loading="isLoading"
    variant="success"
    category="secondary"
    @click="mutate"
    >{{ s__('SecurityConfiguration|Configure via Merge Request') }}</gl-button
  >
</template>
