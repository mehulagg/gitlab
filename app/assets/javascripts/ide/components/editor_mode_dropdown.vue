<script>
import { GlButton, GlDropdown } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { viewerTypes } from '../constants';

export default {
  components: {
    GlButton,
    GlDropdown
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
  <div class="gl-dropdown">
    <gl-button variant="link" data-toggle="gl-dropdown">{{ __('Edit') }}</gl-button>
    <div class="gl-dropdown-menu gl-dropdown-menu-selectable gl-dropdown-open-left">
      <ul>
        <li>
          <a
            :class="{
              'is-active': viewer === $options.viewerTypes.mr,
            }"
            href="#"
            @click.prevent="changeMode($options.viewerTypes.mr)"
          >
            <strong class="gl-dropdown-menu-inner-title"> {{ mergeReviewLine }} </strong>
            <span class="gl-dropdown-menu-inner-content">
              {{ __('Compare changes with the merge request target branch') }}
            </span>
          </a>
        </li>
        <li>
          <a
            :class="{
              'is-active': viewer === $options.viewerTypes.diff,
            }"
            href="#"
            @click.prevent="changeMode($options.viewerTypes.diff)"
          >
            <strong class="gl-dropdown-menu-inner-title">{{ __('Reviewing') }}</strong>
            <span class="gl-dropdown-menu-inner-content">
              {{ __('Compare changes with the last commit') }}
            </span>
          </a>
        </li>
      </ul>
    </div>
  </div>
</template>
