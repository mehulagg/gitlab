<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import updateMixin from '../../mixins/update';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  mixins: [updateMixin],
  props: {
    formState: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <fieldset>
    <label class="sr-only" for="issuable-type">{{ __('Type') }}</label>
    <!-- TODO: this rule still needed? -->
    <!-- eslint-disable vue/no-mutating-props -->
    <input
      id="issuable-type"
      ref="input"
      v-model="formState.type"
      class="form-control qa-type-input"
      dir="auto"
      type="text"
      :placeholder="__('Type')"
      :aria-label="__('Type')"
      @keydown.meta.enter="updateIssuable"
      @keydown.ctrl.enter="updateIssuable"
    />
    <!-- eslint-enable vue/no-mutating-props -->

    <gl-dropdown text="some-dropdown">
      <gl-dropdown-item>{{ __('hello') }}</gl-dropdown-item>
      <gl-dropdown-item>{{ __('there') }}</gl-dropdown-item>
    </gl-dropdown>
  </fieldset>
</template>
