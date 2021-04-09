<script>
import { GlLink } from '@gitlab/ui';
import { mapState, mapGetters, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import createFlash from '~/flash';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __, s__ } from '~/locale';
import { fullEpicId } from '../../boards_util';

export default {
  components: {
    BoardEditableItem,
    EpicsSelect,
    GlLink,
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
    ...mapGetters(['activeBoardItem', 'projectPathForActiveIssue']),
    epic() {
      return this.activeBoardItem.epic;
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
    handleOpen() {
      if (!this.epicFetchInProgress) {
        this.$refs.epicSelect.toggleFormDropdown();
      } else {
        this.$refs.sidebarItem.collapse();
      }
    },
    handleClose() {
      this.$refs.sidebarItem.collapse();
      this.$refs.epicSelect.toggleFormDropdown();
    },
    async setEpic(selectedEpic) {
      this.handleClose();

      const epicId = selectedEpic?.id ? fullEpicId(selectedEpic.id) : null;
      const assignedEpicId = this.epic?.id ? fullEpicId(this.epic.id) : null;
      if (epicId === assignedEpicId) {
        return;
      }

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
    data-testid="sidebar-epic"
    @open="handleOpen"
    @close="handleClose"
  >
    <template v-if="epicData.title" #collapsed>
      <gl-link class="gl-text-gray-900! gl-font-weight-bold" :href="epicData.webPath">
        {{ epicData.title }}
      </gl-link>
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
      @hide="handleClose"
    />
  </board-editable-item>
</template>
