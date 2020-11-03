<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    TimeAgo,
  },
  props: {
    versions: {
      type: Array,
      required: true,
    },
  },
  computed: {
    selectedVersionName() {
      return this.versions.find(x => x.selected)?.versionName || '';
    },
  },
};
</script>

<template>
  <gl-dropdown :text="selectedVersionName">
    <gl-dropdown-item
      v-for="version in versions"
      :key="version.id"
      :is-check-item="true"
      :is-checked="true"
      :class="{ 'is-active': version.selected }"
      :href="version.href"
    >
      <div>
        <strong>
          {{ version.versionName }}
          <template v-if="version.isHead">{{ s__('DiffsCompareBaseBranch|(HEAD)') }}</template>
          <template v-else-if="version.isBase">{{ s__('DiffsCompareBaseBranch|(base)') }}</template>
        </strong>
      </div>
      <div>
        <small class="commit-sha"> {{ version.short_commit_sha }} </small>
      </div>
      <div>
        <small>
          <template v-if="version.commitsText">
            {{ version.commitsText }}
          </template>
          <time-ago v-if="version.created_at" :time="version.created_at" class="js-timeago" />
        </small>
      </div>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
