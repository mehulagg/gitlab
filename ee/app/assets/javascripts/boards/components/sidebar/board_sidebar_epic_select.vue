<script>
import { mapState, mapGetters, mapMutations, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { placeholderEpic } from 'ee/vue_shared/constants';
import issueSetEpic from '~/boards/queries/issue_set_epic.mutation.graphql';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { UPDATE_ISSUE_BY_ID } from '~/boards/stores/mutation_types';

export default {
  components: {
    BoardEditableItem,
    EpicsSelect,
  },
  data() {
    return {
      searchTerm: '',
      selectedEpic: placeholderEpic,
      loading: false,
    };
  },
  inject: ['groupId'],
  computed: {
    ...mapState(['epics', 'endpoints']),
    ...mapGetters({ issue: 'getActiveIssue' }),
    storedEpic() {
      const storedEpic = this.epics.find(epic => epic.id === this.issue.epic?.id);
      const epicId = storedEpic?.id.split('gid://gitlab/Epic/').pop();

      return {
        ...storedEpic,
        id: Number(epicId),
      };
    },
    fullPath() {
      return this.endpoints?.fullPath || '';
    },
    projectPath() {
      const { referencePath = '' } = this.issue;
      return referencePath.slice(0, referencePath.indexOf('#'));
    },
  },
  watch: {
    issue: {
      handler(selectedIssue = {}) {
        this.selectedEpic = selectedIssue.epic;
      },
      immediate: true,
    },
  },
  methods: {
    ...mapMutations({ updateIssueById: UPDATE_ISSUE_BY_ID }),
    ...mapActions(['fetchEpicsSwimlanes', 'refreshEpicsSwimlanes']),
    async handleEdit(isEditing) {
      if (isEditing) {
        await this.$nextTick();
        this.$refs.epicSelect.handleEditClick();
      }
    },
    async setEpic(selectedEpic) {
      this.loading = true;

      this.$refs.sidebarItem.collapse();

      if (!selectedEpic?.id) {
        this.updateIssueById({ issueId: this.issue.id, prop: 'epic', value: null });
        this.loading = false;
        return;
      }

      const { data } = await this.$apollo.mutate({
        mutation: issueSetEpic,
        variables: {
          input: {
            epicId: `gid://gitlab/Epic/${selectedEpic.id}`,
            iid: String(this.issue.iid),
            projectPath: this.projectPath,
          },
        },
      });

      if (data.issueSetEpic.errors?.length > 0) {
        this.selectedEpic = this.issue.epic;
        this.loading = false;

        return;
      }

      const { epic } = data.issueSetEpic.issue;
      this.updateIssueById({ issueId: this.issue.id, prop: 'epic', value: epic });
      this.selectedEpic = epic;
      this.loading = false;
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="sidebarItem"
    :title="__('Epic')"
    :loading="loading"
    @changed="handleEdit"
  >
    <template v-if="storedEpic.title" #collapsed>
      <a class="gl-text-gray-900! gl-font-weight-bold" href="#">
        {{ storedEpic.title }}
      </a>
    </template>
    <template>
      <epics-select
        ref="epicSelect"
        class="gl-w-full"
        :group-id="groupId"
        :can-edit="true"
        :issue-id="0"
        :epic-issue-id="0"
        :initial-epic="storedEpic"
        :initial-epic-loading="false"
        variant="standalone"
        :show-header="false"
        @onEpicSelect="setEpic"
      />
    </template>
  </board-editable-item>
</template>
<style>
.dropdown-menu-toggle {
  width: 100%;
}
</style>
