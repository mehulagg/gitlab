<script>
import { __ } from '~/locale';

export default {
  props: {
    userFields: {
      type: Object,
      required: true,
    },
    groupViewChoices: {
      type: Array,
      default: () => [],
      required: false,
    },
  },
  data() {
    return {
      selectedGroup: this.userFields.groupView,
    };
  },
};
</script>

<template>
  <div v-if="groupViewChoices.length" class="form-group">
    <label class="label-bold" for="user_group_view">
      {{ __('Group overview content') }}
    </label>
    <div class="select-wrapper">
      <select
        v-model="selectedGroup"
        class="form-control select-control"
        name="user[group_view]"
        tabindex="-1"
        title="Group overview content"
      >
        <option
          v-for="[optionName, optionValue] in groupViewChoices"
          :key="optionValue"
          :value="optionValue"
        >
          {{ optionName }}
        </option>
      </select>
      <i aria-hidden="true" class="fa fa-chevron-down"> </i>
    </div>
    <div class="form-text text-muted">
      {{ __('Choose what content you want to see on a group’s overview page.') }}
    </div>
  </div>
</template>
