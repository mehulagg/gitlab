<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
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
  },
  inject: ['groupId'],
  data() {
    return {
      settingEpic: false,
    };
  },
  computed: {
    ...mapState(['epics', 'epicsCache', 'epicFetchInProgress']),
    ...mapGetters(['activeIssue', 'projectPathForActiveIssue']),
    epic() {
      return this.activeIssue.epic;
    },
    loading() {
      return this.settingEpic || this.epicFetchInProgress;
    },
    epicData() {
      return this.epic && !this.epicFetchInProgress ? this.epicsCache[this.epic.id] : {};
    },
    initialEpic() {
      return this.epic
        ? {
            ...this.epicData,
            id: Number(getIdFromGraphQLId(this.epic.id)),
          }
        : {};
    },
  },
  watch: {
    epic: {
      deep: true,
      immediate: true,
      handler() {
        if (this.epic) {
          this.fetchEpicForActiveIssue();
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
      this.settingEpic = true;
      this.$refs.sidebarItem.collapse();

      const epicId = selectedEpic?.id ? `gid://gitlab/Epic/${selectedEpic.id}` : null;
      const input = {
        epicId,
        projectPath: this.projectPathForActiveIssue,
      };

      try {
        await this.setActiveIssueEpic(input);
      } catch (e) {
        createFlash({ message: this.$options.i18n.updateEpicError });
      } finally {
        this.settingEpic = false;
      }
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="sidebarItem"
    :title="$options.i18n.epic"
    :loading="loading"
    @open="openEpicsDropdown"
  >
    <template v-if="epicData.title" #collapsed>
      <a class="gl-text-gray-900! gl-font-weight-bold" href="#">
        {{ epicData.title }}
      </a>
    </template>
    <template v-if="!loading">
      <epics-select
        ref="epicSelect"
        class="gl-w-full"
        :group-id="groupId"
        :can-edit="true"
        :initial-epic="initialEpic"
        :initial-epic-loading="false"
        variant="standalone"
        :show-header="false"
        @onEpicSelect="setEpic"
      />
    </template>
  </board-editable-item>
</template>
