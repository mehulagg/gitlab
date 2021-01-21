<script>
import { mapState, mapGetters, mapMutations, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { debounceByAnimationFrame } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { UPDATE_ISSUE_BY_ID } from '~/boards/stores/mutation_types';
import { RECEIVE_FIRST_EPICS_SUCCESS } from '../../stores/mutation_types';

export default {
  components: {
    BoardEditableItem,
    EpicsSelect,
  },
  inject: ['groupId'],
  data() {
    return {
      loading: false,
    };
  },
  computed: {
    ...mapState(['epics']),
    ...mapGetters(['activeIssue', 'getEpicById', 'projectPathForActiveIssue']),
    storedEpic() {
      const storedEpic = this.getEpicById(this.activeIssue.epic?.id);
      const epicId = getIdFromGraphQLId(storedEpic?.id);

      return {
        ...storedEpic,
        id: Number(epicId),
      };
    },
  },
  methods: {
    ...mapMutations({
      updateIssueById: UPDATE_ISSUE_BY_ID,
      receiveEpicsSuccess: RECEIVE_FIRST_EPICS_SUCCESS,
    }),
    ...mapActions(['setActiveIssueEpic']),
    openEpicsDropdown() {
      this.$refs.epicSelect.handleEditClick();
    },
    async setEpic(selectedEpic) {
      this.loading = true;
      this.$refs.sidebarItem.collapse();

      const epicId = selectedEpic?.id ? `gid://gitlab/Epic/${selectedEpic.id}` : null;
      const input = {
        epicId,
        projectPath: this.projectPathForActiveIssue,
      };

      try {
        const epic = await this.setActiveIssueEpic(input);

        if (epic && !this.getEpicById(epic.id)) {
          this.receiveEpicsSuccess({ epics: [epic, ...this.epics] });
        }

        debounceByAnimationFrame(() => {
          this.updateIssueById({ issueId: this.activeIssue.id, prop: 'epic', value: epic });
          this.loading = false;
        })();
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
    :title="__('Epic')"
    :loading="loading"
    @open="openEpicsDropdown"
  >
    <template v-if="storedEpic.title" #collapsed>
      <a class="gl-text-gray-900! gl-font-weight-bold" href="#">
        {{ storedEpic.title }}
      </a>
    </template>
    <epics-select
      ref="epicSelect"
      class="gl-w-full"
      :group-id="groupId"
      :can-edit="true"
      :initial-epic="storedEpic"
      :initial-epic-loading="false"
      variant="standalone"
      :show-header="false"
      @onEpicSelect="setEpic"
    />
  </board-editable-item>
</template>
