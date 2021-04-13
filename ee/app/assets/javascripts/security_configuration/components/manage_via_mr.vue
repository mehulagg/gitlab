<script>
import { GlButton } from '@gitlab/ui';
import { redirectTo } from '~/lib/utils/url_utility';
import { sprintf, s__ } from '~/locale';
import apolloProvider from '../graphql/provider';
import { featureToMutationMap } from './constants';

export default {
  apolloProvider,
  components: {
    GlButton,
  },
  inject: {
    projectPath: {
      from: 'projectPath',
      default: '',
    },
  },
  props: {
    feature: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
    };
  },
  computed: {
    featureSettings() {
      return featureToMutationMap[this.feature.type];
    },
  },
  methods: {
    async mutate() {
      this.isLoading = true;
      try {
        const { data } = await this.$apollo.mutate({
          mutation: this.featureSettings.mutation,
          variables: {
            fullPath: this.projectPath,
          },
        });
        const { errors, successPath } = data[this.featureSettings.type];

        if (errors.length > 0) {
          throw new Error(errors[0]);
        }

        if (!successPath) {
          throw new Error(
            sprintf(this.$options.i18n.noSuccessPathError, { featureName: this.feature.name }),
          );
        }

        redirectTo(successPath);
      } catch (e) {
        this.$emit('error', e.message);
        this.isLoading = false;
      }
    },
  },
  i18n: {
    buttonLabel: s__('SecurityConfiguration|Configure via Merge Request'),
    noSuccessPathError: s__(
      'SecurityConfiguration|%{featureName} merge request creation mutation failed',
    ),
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
    >{{ $options.i18n.buttonLabel }}</gl-button
  >
</template>
