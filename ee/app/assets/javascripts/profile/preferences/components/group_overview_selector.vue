<script>
import { i18n } from '../constants';

export default {
  name: 'GroupOverviewSelector',
  inject: {
    userFields: 'userFields',
    groupViewChoices: {
      default: [],
    },
  },
  data() {
    return {
      selectedGroup: this.userFields.group_view,
    };
  },
  i18n,
};
</script>

<template>
  <div v-if="groupViewChoices.length" class="form-group">
    <label
      class="label-bold"
      for="user_group_view"
      data-testid="profile-preferences-group-overview-heading"
    >
      {{ $options.i18n.groupOverview }}
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
          data-testid="profile-preferences-group-overview-option"
          :value="optionValue"
        >
          {{ optionName }}
        </option>
      </select>
      <i aria-hidden="true" class="fa fa-chevron-down"> </i>
    </div>
    <div class="form-text text-muted">
      {{ $options.i18n.groupOverviewDescription }}
    </div>
  </div>
</template>
