<script>
import { GlFormCheckbox, GlIcon, GlLink, GlPopover } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { __ } from '~/locale';
import { APPROVALS_HELP_PATH } from '../constants';

export default {
  components: {
    GlFormCheckbox,
    GlIcon,
    GlLink,
    GlPopover,
  },
  props: {
    label: {
      type: String,
      required: true,
    },
    anchor: {
      type: String,
      required: true,
    },
    value: {
      type: Boolean,
      required: false,
      default: false,
    },
    lockedBy: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    href() {
      return helpPagePath(APPROVALS_HELP_PATH, { anchor: this.anchor });
    },
    settingLocked() {
      return Boolean(this.lockedBy);
    },
  },
  methods: {
    input(value) {
      this.$emit('input', value);
    },
  },
  i18n: {
    helpLabel: __('Help'),
    lockIconTitle: __('Setting enforced'),
  },
};
</script>

<template>
  <gl-form-checkbox :disabled="settingLocked" :checked="value" @input="input">
    {{ label }}
    <template v-if="settingLocked">
      <gl-icon ref="lockIcon" data-testid="lock-icon" name="lock" />
      <gl-popover
        :target="() => $refs.lockIcon.$el"
        container="viewport"
        placement="top"
        :title="$options.i18n.lockIconTitle"
        triggers="hover focus"
        :content="lockedBy"
      />
    </template>
    <gl-link :href="href" target="_blank">
      <gl-icon
        data-testid="help-icon"
        name="question-o"
        :aria-label="$options.i18n.helpLabel"
        :size="16"
      />
    </gl-link>
  </gl-form-checkbox>
</template>
