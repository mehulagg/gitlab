<script>
import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';

export default {
  data() {
    return {
      branches: [],
      isDropdownShowing: false,
      searchTerm: '',
      selectedBranch: this.getDefaultBranch(),
    };
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  props: {
    refsProjectPath: {
      type: String,
      required: true,
    },
    revisionText: {
      type: String,
      required: true,
    },
    params: {
      type: String,
      required: true,
    },
    paramsBranch: {
      type: String,
      required: true,
    },
  },
  mounted() {
    this.updateBranchesDropdown();
  },
  computed: {
    filteredBranches() {
      return this.branches.filter((branch) =>
        branch.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    filteredBranchesLength() {
      return this.filteredBranches.length === 0;
    },
  },
  methods: {
    updateBranchesDropdown() {
      const endpoint = gon.gitlab_url + this.refsProjectPath;
      this.isDropdownSearching = true;

      return axios
        .get(endpoint)
        .then(({ data }) => {
          this.branches = data.Branches;
        })
        .catch(() => {
          console.log('error');
          // gl-alert, see "app/assets/javascripts/alert_management/components/alert_details.vue"
          this.$emit(
            'alert-error',
            s__(
              'CompareBranches|There was an error while updating the branch list. Please try again.',
            ),
          );
        })
        .finally(() => {
          this.isDropdownSearching = false;
        });
    },
    getDefaultBranch() {
      return this.paramsBranch;
    },
    onClick(branch) {
      this.selectedBranch = branch;
    },
  },
};
</script>

<template>
  <div class="form-group compare-form-group" :class="`js-compare-${params}-dropdown`">
    <div class="input-group inline-input-group">
      <span class="input-group-prepend">
        <div class="input-group-text">
          {{ s__(`CompareBranches|${revisionText}`) }}
        </div>
      </span>
      <input type="hidden" :name="params" :value="selectedBranch" />
      <!-- Need to implement tooltip -->
      <gl-dropdown
        class="gl-flex-grow-1 gl-flex-basis-0 gl-min-w-0"
        toggle-class="gl-min-w-0 form-control compare-dropdown-toggle js-compare-dropdown has-tooltip gl-rounded-top-left-none! gl-rounded-bottom-left-none!"
        :text="selectedBranch"
        header-text="Select Git revision"
      >
        <template #header>
          <gl-search-box-by-type
            v-model.trim="searchTerm"
            :placeholder="s__('CompareBranches|Filter by Git revision')"
          />
        </template>
        <gl-dropdown-item
          v-for="(branch, index) in filteredBranches"
          :key="index"
          :is-check-item="true"
          :is-checked="selectedBranch === branch"
          @click="onClick(branch)"
        >
          {{ branch }}
        </gl-dropdown-item>
        <div v-show="filteredBranchesLength" class="text-secondary p-2">
          {{ s__('CompareBranches|Nothing found...') }}
        </div>
      </gl-dropdown>
    </div>
  </div>
</template>
