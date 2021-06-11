<script>
import { isEmpty } from 'lodash';
import { mapState, mapActions } from 'vuex';
import { visitUrl, setUrlParams } from '~/lib/utils/url_utility';
import { GROUPS_LOCAL_STORAGE_KEY } from '~/search/store/constants';
import { ANY_OPTION, GROUP_DATA, PROJECT_DATA } from '../constants';
import SearchableDropdown from './searchable_dropdown.vue';

export default {
  name: 'GroupFilter',
  components: {
    SearchableDropdown,
  },
  props: {
    initialData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    ...mapState(['groups', 'fetchingGroups']),
    selectedGroup() {
      return isEmpty(this.initialData) ? ANY_OPTION : this.initialData;
    },
  },
  created() {
    this.getFrequentItemLS(GROUPS_LOCAL_STORAGE_KEY);
  },
  methods: {
    ...mapActions(['fetchGroups', 'getFrequentItemLS', 'setFrequentItemLS']),
    async handleGroupChange(group) {
      if (group.id) {
        await this.setFrequentItemLS({ item: group, lsKey: GROUPS_LOCAL_STORAGE_KEY });
      }

      visitUrl(
        setUrlParams({ [GROUP_DATA.queryParam]: group.id, [PROJECT_DATA.queryParam]: null }),
      );
    },
  },
  GROUP_DATA,
};
</script>

<template>
  <searchable-dropdown
    data-testid="group-filter"
    :header-text="$options.GROUP_DATA.headerText"
    :name="$options.GROUP_DATA.name"
    :full-name="$options.GROUP_DATA.fullName"
    :loading="fetchingGroups"
    :selected-item="selectedGroup"
    :items="groups"
    @search="fetchGroups"
    @change="handleGroupChange"
  />
</template>
