<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlDropdownSectionHeader,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { filterGitlabCiYmls } from './helpers';

export default {
  name: 'CiTemplateDropdown',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlDropdownSectionHeader,
    GlSearchBoxByType,
  },
  inject: {
    initialSelectedGitlabCiYmlName: {
      default: null,
    },
    gitlabCiYmls: {
      default: {},
    },
  },
  data() {
    return {
      selectedGitlabCiYmlName: this.initialSelectedGitlabCiYmlName,
      searchTerm: '',
    };
  },
  computed: {
    filteredYmls() {
      if (!this.searchTerm) {
        return this.gitlabCiYmls;
      }

      return filterGitlabCiYmls(this.gitlabCiYmls, this.searchTerm);
    },
    filteredTemplateCategories() {
      return Object.keys(this.filteredYmls);
    },
    dropdownText() {
      return this.selectedGitlabCiYmlName || this.$options.i18n.defaultDropdownText;
    },
    selectedGitlabCiYmlValue() {
      return this.selectedGitlabCiYmlName;
    },
  },
  methods: {
    isDropdownItemChecked(gitlabCiYml) {
      return this.selectedGitlabCiYmlName === gitlabCiYml.name;
    },
    onDropdownItemClick(gitlabCiYml) {
      if (this.selectedGitlabCiYmlName === gitlabCiYml.name) {
        this.selectedGitlabCiYmlName = null;
      } else {
        this.selectedGitlabCiYmlName = gitlabCiYml.name;
      }
    },
  },
  i18n: {
    defaultDropdownHeaderText: s__('AdminSettings|Select a CI/CD template'),
    defaultDropdownText: s__('AdminSettings|No required pipeline'),
  },
  TYPING_DELAY: 100, // offset user's typing slightly to potentially save excessive DOM updates
};
</script>

<template>
  <div>
    <input
      id="required_instance_ci_template_name"
      type="hidden"
      name="application_setting[required_instance_ci_template]"
      :value="selectedGitlabCiYmlValue"
    />
    <gl-dropdown
      :text="dropdownText"
      :header-text="$options.i18n.defaultDropdownHeaderText"
      no-flip
      class="gl-display-block gl-m-0"
    >
      <template #header>
        <gl-search-box-by-type v-model.trim="searchTerm" :debounce="$options.TYPING_DELAY" />
      </template>

      <div v-for="categoryName in filteredTemplateCategories" :key="categoryName">
        <gl-dropdown-divider />
        <gl-dropdown-section-header>
          {{ categoryName }}
        </gl-dropdown-section-header>
        <gl-dropdown-item
          v-for="gitlabCiYml in filteredYmls[categoryName]"
          :key="gitlabCiYml.id"
          is-check-item
          :is-checked="isDropdownItemChecked(gitlabCiYml)"
          @click="onDropdownItemClick(gitlabCiYml)"
        >
          {{ gitlabCiYml.name }}
        </gl-dropdown-item>
      </div>
    </gl-dropdown>
  </div>
</template>
