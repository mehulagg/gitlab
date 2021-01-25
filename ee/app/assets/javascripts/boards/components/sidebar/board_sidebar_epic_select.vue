<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { fullEpicId } from '../../boards_util';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import createFlash from '~/flash';
import { __, s__ } from '~/locale';

export default {
  components: {
    BoardEditableItem,
    EpicsSelect,
  },
  i18n: {
    epic: __('Epic'),
    updateEpicError: s__(
      'IssueBoards|An error occurred while assigning the selected epic to the issue.',
    ),
    fetchEpicError: s__(
      'IssueBoards|An error occurred while fetching the assigned epic of the selected issue.',
    ),
  },
  inject: ['groupId'],
  computed: {
    ...mapState(['epics', 'epicsCacheById', 'epicFetchInProgress']),
    ...mapGetters(['activeIssue', 'projectPathForActiveIssue']),
    epic() {
      return this.activeIssue.epic;
    },
    epicData() {
      const hasEpic = this.epic !== null;
      const epicFetched = !this.epicFetchInProgress;

      return hasEpic && epicFetched ? this.epicsCacheById[this.epic.id] : {};
    },
    initialEpic() {
      return this.epic
        ? {
            ...this.epicData,
            id: getIdFromGraphQLId(this.epic.id),
          }
        : {};
    },
  },
  watch: {
    epic: {
      deep: true,
      immediate: true,
      async handler() {
        if (this.epic) {
          try {
            await this.fetchEpicForActiveIssue();
          } catch (e) {
            createFlash({
              message: this.$options.i18n.fetchEpicError,
              error: e,
              captureError: true,
            });
          }
        }
      },
    },
  },
  methods: {
    ...mapActions(['setActiveIssueEpic', 'fetchEpicForActiveIssue']),
    openEpicsDropdown() {
      if (!this.loading) {
        this.$refs.epicSelect.handleEditClick();
      }
    },
    async setEpic(selectedEpic) {
      this.$refs.sidebarItem.collapse();

      const epicId = selectedEpic?.id ? fullEpicId(selectedEpic.id) : null;

      try {
        await this.setActiveIssueEpic(epicId);
      } catch (e) {
        createFlash({ message: this.$options.i18n.updateEpicError, error: e, captureError: true });
      }
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="sidebarItem"
    :title="$options.i18n.epic"
    :loading="epicFetchInProgress"
    @open="openEpicsDropdown"
  >
    <template v-if="epicData.title" #collapsed>
      <a class="gl-text-gray-900! gl-font-weight-bold" href="#">
        {{ epicData.title }}
      </a>
    </template>
    <epics-select
      v-if="!epicFetchInProgress"
      ref="epicSelect"
      class="gl-w-full"
      :group-id="groupId"
      :can-edit="true"
      :initial-epic="initialEpic"
      :initial-epic-loading="false"
      variant="standalone"
      :show-header="false"
      @epicSelect="setEpic"
    />
  </board-editable-item>
</template>
