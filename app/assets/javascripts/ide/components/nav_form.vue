<script>
import { GlTabs, GlTab } from '@gitlab/ui';
import BranchesSearchList from './branches/search_list.vue';
import MergeRequestSearchList from './merge_requests/list.vue';

export default {
  components: {
    GlTabs,
    GlTab,
    BranchesSearchList,
    MergeRequestSearchList,
  },
  props: {
    showMergeRequests: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
};
</script>

<template>
  <div class="ide-nav-form p-0">
    <gl-tabs theme="indigo" v-if="showMergeRequests" stop-propagation>
      <gl-tab title="Branches">
        <branches-search-list />
      </gl-tab>
      <gl-tab title="Merge Requests">
        <merge-request-search-list />
      </gl-tab>
    </gl-tabs>
    <branches-search-list v-else />
  </div>
</template>


<!-- <template>
  <div class="ide-nav-form p-0">
    <tabs v-if="showMergeRequests" stop-propagation>
      <tab active>
        <template #title>
          {{ __('Branches') }}
        </template>
        <branches-search-list />
      </tab>
      <tab>
        <template #title>
          {{ __('Merge Requests') }}
        </template>
        <merge-request-search-list />
      </tab>
    </tabs>
    <branches-search-list v-else />
  </div>
</template>
 -->