<script>
import { mapState, mapGetters, mapMutations, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { debounceByAnimationFrame } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { UPDATE_ISSUE_BY_ID } from '~/boards/stores/mutation_types';
import { RECEIVE_FIRST_EPICS_SUCCESS } from '../../stores/mutation_types';
import createFlash from '~/flash';
import { __, s__ } from '~/locale';
import { fetchPolicies } from '~/lib/graphql';
import epicQuery from '../../graphql/epic_query.graphql';

export default {
  components: {
    BoardEditableItem,
    EpicsSelect,
  },
  i18n: {
    epic: __('Epic'),
    fetchEpicError: s__('IssueBoards|An error occurred while fetching the assigned epic.'),
  },
  inject: ['groupId'],
  data() {
    return {
      assignedEpic: {},
      loadingEpic: 0,
      settingEpic: false,
      epicIid: null,
    };
  },
  apollo: {
    assignedEpic: {
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      query: epicQuery,
      loadingKey: 'loadingEpic',
      skip() {
        return !this.epic || !this.epicIid;
      },
      variables() {
        return {
          fullPath: this.groupFullPath,
          iid: this.epic.iid,
        };
      },
      update(data) {
        const epic = data?.group?.epic;

        return {
          ...epic,
          id: Number(getIdFromGraphQLId(epic?.id)),
        };
      },
      error() {
        createFlash({ message: this.$options.i18n.fetchEpicError });
      },
    },
  },
  computed: {
    ...mapState(['epics']),
    ...mapGetters(['activeIssue', 'getEpicById', 'projectPathForActiveIssue']),
    groupFullPath() {
      const { referencePath = '' } = this.activeIssue;
      return referencePath.slice(0, referencePath.indexOf('/'));
    },
    epic() {
      return this.activeIssue.epic;
    },
    loading() {
      return this.loadingEpic > 0 || this.settingEpic;
    },
    epicTitle() {
      return this.loading || !this.epic ? '' : this.assignedEpic.title;
    },
  },
  watch: {
    epic: {
      deep: true,
      immediate: true,
      handler() {
        if (this.epic) {
          this.epicIid = this.epic.iid;
        }
      },
    },
  },
  methods: {
    ...mapMutations({
      updateIssueById: UPDATE_ISSUE_BY_ID,
      receiveEpicsSuccess: RECEIVE_FIRST_EPICS_SUCCESS,
    }),
    ...mapActions(['setActiveIssueEpic']),
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
        const epic = await this.setActiveIssueEpic(input);

        if (epic && !this.getEpicById(epic.id)) {
          this.receiveEpicsSuccess({ epics: [epic, ...this.epics] });
        }

        // TODO Avoid calling mutations (receiveEpicsSucces, updateIssueByID)
        //      and remove debounceAnimationFrame:
        // https://gitlab.com/gitlab-org/gitlab/-/issues/255995
        debounceByAnimationFrame(() => {
          this.updateIssueById({ issueId: this.activeIssue.id, prop: 'epic', value: epic });
          this.settingEpic = false;
        })();
      } catch (e) {
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
    <template v-if="epicTitle" #collapsed>
      <a class="gl-text-gray-900! gl-font-weight-bold" href="#">
        {{ epicTitle }}
      </a>
    </template>
    <template v-if="!loading">
      <epics-select
        ref="epicSelect"
        class="gl-w-full"
        :group-id="groupId"
        :can-edit="true"
        :initial-epic="assignedEpic"
        :initial-epic-loading="loading"
        variant="standalone"
        :show-header="false"
        @onEpicSelect="setEpic"
      />
    </template>
  </board-editable-item>
</template>
