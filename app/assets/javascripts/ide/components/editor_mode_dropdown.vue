<script>
import { GlButton, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { viewerTypes } from '../constants';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    viewer: {
      type: String,
      required: true,
    },
    mergeRequestId: {
      type: Number,
      required: true,
    },
  },
  computed: {
    mergeReviewLine() {
      return sprintf(__('Reviewing (merge request !%{mergeRequestId})'), {
        mergeRequestId: this.mergeRequestId,
      });
    },
  },
  methods: {
    changeMode(mode) {
      this.$emit('click', mode);
    },
  },
  viewerTypes,
};
</script>

<template>
  <gl-dropdown :text="__('Edit')" :size="__('small')">
    <gl-dropdown-item
      href="#"
      :is-check-item="true"
      :is-checked="viewer === $options.viewerTypes.mr"
      @click.prevent="changeMode($options.viewerTypes.mr)"
    >
      <strong class="dropdown-menu-inner-title"> {{ mergeReviewLine }} </strong>
      <span class="dropdown-menu-inner-content">
        {{ __('Compare changes with the merge request target branch') }}
      </span>
    </gl-dropdown-item>
    <gl-dropdown-item
      href="#"
      :is-check-item="true"
      :is-checked="viewer === $options.viewerTypes.diff"
      @click.prevent="changeMode($options.viewerTypes.diff)"
    >
      <strong class="dropdown-menu-inner-title">{{ __('Reviewing') }}</strong>
      <span class="dropdown-menu-inner-content">
        {{ __('Compare changes with the last commit') }}
      </span>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
