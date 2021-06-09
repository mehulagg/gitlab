<script>
import { GlSprintf } from '@gitlab/ui';
import { isUserBusy } from '~/set_status_modal/utils';

export default {
  name: 'UserNameWithStatus',
  components: {
    GlSprintf,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
    containerClasses: {
      type: String,
      required: false,
      default: '',
    },
    availability: {
      type: String,
      required: false,
      default: '',
    },
    pronouns: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    isBusy() {
      return isUserBusy(this.availability);
    },
    hasPronouns() {
      return Boolean(this.pronouns);
    },
    isBusyAndHasPronouns() {
      return this.isBusy && this.hasPronouns
    }
  },
};
</script>
<template>
  <span :class="containerClasses">
  <template v-if="isBusyAndHasPronouns">
    <gl-sprintf :message="s__('UserAvailability|%{author} %{pronouns} (Busy)')">
      <template #author>{{ name }}</template>
      <template #pronouns>
        <span class="gl-font-sm">({{ pronouns }})</span>
      </template>
    </gl-sprintf>
  </template>
  <template v-else-if="isBusy">
    <gl-sprintf :message="s__('UserAvailability|%{author} (Busy)')">
      <template #author>{{ name }}</template>
    </gl-sprintf>
  </template>
  <template v-else-if="hasPronouns">
    <gl-sprintf :message="s__('UserAvailability|%{author} %{pronouns}')">
      <template #author>{{ name }}</template>
      <template #pronouns>
        <span class="gl-font-sm">({{ pronouns }})</span>
      </template>
    </gl-sprintf>
  </template>
  <template v-else>{{ name }}</template>
  </span>
</template>
