<script>
import { GlDropdown, GlSearchBoxByType, GlDropdownItem } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'CiTemplateDropdown',
  components: { GlDropdown, GlSearchBoxByType, GlDropdownItem },
  props: {
    gitlabCiYmls: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      selectedGitlabCiYml: {
        id: s__('Android'),
        name: s__('Android'),
      },
      searchTerm: '',
    };
  },
};
</script>

<template>
  <gl-dropdown
    :text="selectedGitlabCiYml.name"
    :header-text="s__('SelectTemplate|Select template')"
  >
    <template #header>
      <gl-search-box-by-type v-model.trim="searchTerm" />
    </template>
    <gl-dropdown-item
      v-for="gitlabCiYml in gitlabCiYmls.General"
      :key="gitlabCiYml.id"
      is-check-item
      :is-checked="selectedGitlabCiYml.id === gitlabCiYml.id"
    >
      {{ gitlabCiYml.name }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
