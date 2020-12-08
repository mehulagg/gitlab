<script>
import { GlModal, GlSprintf } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import updateCanaryIngress from '../graphql/mutations/update_canary_ingress.graphql';

export default {
  components: {
    GlModal,
    GlSprintf,
  },
  props: {
    environment: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    weight: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  translations: {
    title: s__('CanaryIngress|Do you want to change your canary roll out?'),
    ratioChange: s__(
      'CanaryIngress|You are changing the ratio of the canary rollout for %{environment} compared to the stable deployment to:',
    ),
    stableWeight: s__('CanaryIngress|%{boldStart}Stable:%{boldEnd} %{stable}'),
    canaryWeight: s__('CanaryIngress|%{boldStart}Canary:%{boldEnd} %{canary}'),
    deploymentWarning: s__(
      'CanaryIngress|Doing so will set a deployment change in progress. This temporarily blocks any further configuration until the deployment is finished.',
    ),
  },
  modal: {
    modalId: 'confirm-canary-change',
    actionPrimary: {
      text: s__('CanaryIngress|Change increment'),
      attributes: [{ variant: 'info' }],
    },
    actionCancel: { text: __('Cancel') },
  },
  computed: {
    stableWeight() {
      return (100 - this.weight).toString();
    },
    canaryWeight() {
      return this.weight.toString();
    },
    ratioChange() {
      return sprintf(this.$options.translations.ratioChange, {
        environment: this.environment?.name ?? '',
      });
    },
  },
  methods: {
    submitCanaryChange() {
      return this.$apollo.mutate({
        mutation: updateCanaryIngress,
        variables: {
          input: {
            id: this.environment.global_id,
            weight: this.weight,
          },
        },
      });
    },
    show() {
      this.$refs['canary-change-modal'].show();
    },
  },
};
</script>
<template>
  <gl-modal ref="canary-change-modal" v-bind="$options.modal" @primary="submitCanaryChange">
    <template #modal-title>{{ $options.translations.title }}</template>
    <template #default>
      <p>{{ ratioChange }}</p>
      <ul class="gl-list-style-none gl-p-0">
        <li>
          <gl-sprintf :message="$options.translations.stableWeight">
            <template #bold="{ content }">
              <span class="gl-font-weight-bold">{{ content }}</span>
            </template>
            <template #stable>{{ stableWeight }}</template>
          </gl-sprintf>
        </li>
        <li>
          <gl-sprintf :message="$options.translations.canaryWeight">
            <template #bold="{ content }">
              <span class="gl-font-weight-bold">{{ content }}</span>
            </template>
            <template #canary>{{ canaryWeight }}</template>
          </gl-sprintf>
        </li>
      </ul>
      <p>{{ $options.translations.deploymentWarning }}</p>
    </template>
  </gl-modal>
</template>
