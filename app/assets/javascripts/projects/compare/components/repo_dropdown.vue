<script>
import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  props: {
    paramsName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      repos: [],
      loading: true,
      searchTerm: '',
      // selectedRepo: this.getDefaultBranch(),
      selectedRepo: 'namespace/project',
    };
  },
  computed: {
    filteredRepos() {
      return this.repos?.filter((tag) => tag.toLowerCase().includes(this.searchTerm.toLowerCase()));
    },
    hasFilteredRepos() {
      return this.filteredRepos?.length;
    },
  },
  mounted() {
    this.fetchRepos();
  },
  methods: {
    fetchRepos() {
      this.repos = ['repo-1', 'repo-2'];
      // const endpoint = this.refsProjectPath;

      // SAM: communicate with BE for endpoint
      // return axios
      //   .get(endpoint)
      //   .then(({ data }) => {
      //     this.branches = data.Branches;
      //     this.tags = data.Tags;
      //   })
      //   .catch(() => {
      //     createFlash({
      //       message: `${s__(
      //         'CompareRevisions|There was an error while updating the branch/tag list. Please try again.',
      //       )}`,
      //     });
      //   })
      //   .finally(() => {
      //     this.loading = false;
      //   });
    },
    onClick(repo) {
      this.selectedRepo = repo;
    },
    // getDefaultBranch() {
    //   return this.paramsBranch || s__('CompareRevisions|Select branch/tag');
    // },
  },
};
</script>

<template>
  <div class="compare-form-group">
    <!-- SAM: communicate with BE for input name -->
    <input type="hidden" :name="`${paramsName}_repo`" :value="selectedRepo" />
    <gl-dropdown
      :text="selectedRepo"
      header-text="Header"
      class="gl-w-full gl-font-monospace gl-sm-pr-3"
    >
      <template #header>
        <gl-search-box-by-type v-model.trim="searchTerm" />
      </template>
      <gl-dropdown-item v-for="(repo, index) in filteredRepos" :key="index" @click="onClick(repo)">
        {{ repo }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
