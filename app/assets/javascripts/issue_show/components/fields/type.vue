<script>
import { GlDropdown, GlDropdownForm, GlDropdownItem } from '@gitlab/ui';
import updateMixin from '../../mixins/update';

export default {
  components: {
    GlDropdown,
    GlDropdownForm,
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
    <!-- <input
      ref="input"
      class="form-control qa-type-input"
      dir="auto"
      type="text"
    /> -->

    <gl-dropdown :aria-label="__('Type')" :placeholder="__('Type')" text="some-dropdown">
      <!-- TODO: this rule still needed? -->
      <!-- eslint-disable vue/no-mutating-props -->
      <gl-dropdown-form
        id="issuable-type"
        v-model="formState.type"
        @keydown.meta.enter="updateIssuable"
        @keydown.ctrl.enter="updateIssuable"
      >
        <gl-dropdown-item>{{ __('hello') }}</gl-dropdown-item>
        <gl-dropdown-item>{{ __('there') }}</gl-dropdown-item>
      </gl-dropdown-form>
      <!-- eslint-enable vue/no-mutating-props -->
    </gl-dropdown>
  </fieldset>
</template>
