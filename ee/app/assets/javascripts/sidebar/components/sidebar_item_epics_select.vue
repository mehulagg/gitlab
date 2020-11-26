<script>
import { noneEpic } from 'ee/vue_shared/constants';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default {
  components: {
    EpicsSelect,
  },
  props: {
    canEdit: {
      type: Boolean,
      required: true,
    },
    sidebarStore: {
      type: Object,
      required: true,
    },
    groupId: {
      type: Number,
      required: true,
    },
    issueId: {
      type: Number,
      required: false,
      default: 0,
    },
    epicIssueId: {
      type: Number,
      required: true,
      default: 0,
    },
    initialEpic: {
      type: Object,
      required: false,
      default: () => null,
    },
  },
  data() {
    return {
      initialEpicLoading: this.getInitialEpicLoading(),
      epic: this.getEpic(),
    };
  },
  watch: {
    /**
     * sidebarStore is updated async while in Issue Boards
     * hence we need a _deep watch_ to update `initialEpicLoading`
     * and `epic` props.
     */
    sidebarStore: {
      handler() {
        this.initialEpicLoading = this.getInitialEpicLoading();
        this.epic = convertObjectPropsToCamelCase(this.getEpic());
      },
      deep: true,
    },
  },
  methods: {
    getInitialEpicLoading() {
      if (this.initialEpic) {
        return false;
      } else if (this.sidebarStore.isFetching) {
        // We need to cast `epic` into boolean as when
        // new issue is created from board, `isFetching`
        // does not contain `epic` within it.
        return Boolean(this.sidebarStore.isFetching.epic);
      }
      return false;
    },
    getEpic() {
      if (this.initialEpic) {
        return this.initialEpic;
      } else if (this.sidebarStore.epic && this.sidebarStore.epic.id) {
        return this.sidebarStore.epic;
      }
      return noneEpic;
    },
  },
};
</script>

<template>
  <epics-select
    :group-id="groupId"
    :issue-id="issueId"
    :epic-issue-id="epicIssueId"
    :can-edit="canEdit"
    :initial-epic="epic"
    :initial-epic-loading="initialEpicLoading"
  >
    {{ __('None') }}
  </epics-select>
</template>
