<script>
import { mapGetters, mapActions } from 'vuex';
import { GlDropdown, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import groupMilestones from '../../queries/group_milestones.query.graphql';
import { __ } from '~/locale';

export default {
  components: {
    BoardEditableItem,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
  },
  data() {
    return {
      milestones: [],
      loading: false,
      edit: false,
    };
  },
  apollo: {
    milestones: {
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      query: groupMilestones,
      skip() {
        return !this.edit;
      },
      variables() {
        return {
          fullPath: this.groupFullPath,
          state: 'active',
          includeDescendants: true,
        };
      },
      update(data) {
        const edges = data?.group?.milestones?.edges ?? [];
        return edges.map(item => item.node);
      },
      error(error) {
        console.log(error);
      },
    },
  },
  computed: {
    ...mapGetters({ issue: 'getActiveIssue' }),
    hasMilestone() {
      return this.issue.milestone !== null;
    },
    groupFullPath() {
      const { referencePath = '' } = this.issue;
      return referencePath.slice(0, referencePath.indexOf('/'));
    },
    projectPath() {
      const { referencePath = '' } = this.issue;
      return referencePath.slice(0, referencePath.indexOf('#'));
    },
    dropdownText() {
      return this.issue.milestone?.title ?? __('No milestone');
    },
  },
  methods: {
    ...mapActions(['setActiveIssueMilestone']),
    async setMilestone(milestoneId) {
      this.loading = true;
      this.$refs.sidebarItem.collapse();

      try {
        const input = { milestoneId, projectPath: this.projectPath };
        await this.setActiveIssueMilestone(input);
        this.loading = false;
      } catch (e) {
        this.loading = false;
      }
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="sidebarItem"
    :title="__('Milestone')"
    :loading="loading"
    @open="edit = true"
    @close="edit = false"
  >
    <template v-if="hasMilestone" #collapsed>
      <strong class="gl-text-gray-900">{{ issue.milestone.title }}</strong>
    </template>
    <template>
      <gl-dropdown :text="dropdownText" :header-text="__('Assign milestone')" block>
        <gl-dropdown-item @click="setMilestone(null)">{{ __('No milestone') }}</gl-dropdown-item>
        <gl-dropdown-divider />
        <gl-dropdown-item
          v-for="milestone in milestones"
          :key="milestone.id"
          :is-check-item="true"
          :is-checked="issue.milestone && milestone.id === issue.milestone.id"
          @click="setMilestone(milestone.id)"
        >
          {{ milestone.title }}
        </gl-dropdown-item>
      </gl-dropdown>
    </template>
  </board-editable-item>
</template>
