<script>
import { GlFormCheckbox, GlIcon, GlLink } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { __ } from '~/locale';
import { APPROVALS_HELP_PATH } from '../constants';

export default {
  components: {
    GlFormCheckbox,
    GlIcon,
    GlLink,
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
  },
  computed: {
    href() {
      return helpPagePath(APPROVALS_HELP_PATH, { anchor: this.anchor });
    },
  },
  methods: {
    input(value) {
      this.$emit('input', value);
    },
  },
  i18n: {
    helpLabel: __('Help'),
  },
};
</script>

<template>
  <gl-form-checkbox :checked="value" @input="input">
    {{ label }}
    <gl-link :href="href" target="_blank">
      <gl-icon name="question-o" :aria-label="$options.i18n.helpLabel" :size="16" />
    </gl-link>
  </gl-form-checkbox>
</template>
