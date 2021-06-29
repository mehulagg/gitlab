<script>
import { GlLoadingIcon, GlIcon } from '@gitlab/ui';
import MilestoneSelect from '~/milestone_select';

const ANY_MILESTONE = 'Any milestone';
const NO_MILESTONE = 'No milestone';

export default {
  components: {
    GlLoadingIcon,
    GlIcon,
  },
  props: {
    board: {
      type: Object,
      required: true,
    },
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    projectId: {
      type: Number,
      required: false,
      default: 0,
    },
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
  },

  computed: {
    milestoneTitle() {
      if (this.noMilestone) return NO_MILESTONE;
      return this.board.milestone ? this.board.milestone.title : ANY_MILESTONE;
    },
    noMilestone() {
      return this.milestoneId === 0;
    },
    milestoneId() {
      return this.board.milestone_id;
    },
    milestoneTitleClass() {
      return this.milestoneTitle === ANY_MILESTONE ? 'text-secondary' : 'bold';
    },
    selected() {
      if (this.noMilestone) return NO_MILESTONE;
      return this.board.milestone ? this.board.milestone.name : '';
    },
  },
  mounted() {
    this.milestoneDropdown = new MilestoneSelect(null, this.$refs.dropdownButton, {
      handleClick: this.selectMilestone,
    });
  },
  methods: {
    selectMilestone(milestone) {
      let { id } = milestone;
      // swap the IDs of 'Any' and 'No' milestone to what backend requires
      if (milestone.title === ANY_MILESTONE) {
        id = -1;
      } else if (milestone.title === NO_MILESTONE) {
        id = 0;
      }
      // eslint-disable-next-line vue/no-mutating-props
      this.board.milestone_id = id;
      // eslint-disable-next-line vue/no-mutating-props
      this.board.milestone = {
        ...milestone,
        id,
      };
    },
  },
};
</script>

<template>
  <div class="block milestone">
    <div class="title gl-mb-3">
      {{ __('Milestone') }}
      <button v-if="canEdit" type="button" class="edit-link btn btn-blank float-right">
        {{ __('Edit') }}
      </button>
    </div>
    <div :class="milestoneTitleClass" class="value">{{ milestoneTitle }}</div>
    <div class="selectbox" style="display: none">
      <input :value="milestoneId" name="milestone_id" type="hidden" />
      <div class="dropdown">
        <!-- eslint-disable @gitlab/vue-no-data-toggle -->
        <button
          ref="dropdownButton"
          :data-selected="selected"
          :data-project-id="projectId"
          :data-group-id="groupId"
          :data-show-no="true"
          :data-show-any="true"
          :data-show-started="true"
          :data-show-upcoming="true"
          :data-use-id="true"
          class="dropdown-menu-toggle wide"
          data-toggle="dropdown"
          type="button"
        >
          {{ __('Milestone') }}
          <gl-icon
            name="chevron-down"
            class="gl-absolute gl-top-3 gl-right-3 gl-text-gray-500"
            :size="16"
          />
        </button>
        <!-- eslint-enable @gitlab/vue-no-data-toggle -->

        <div class="dropdown-menu dropdown-select dropdown-menu-selectable">
          <div class="dropdown-input">
            <input
              type="search"
              class="dropdown-input-field"
              :placeholder="__('Search milestones')"
              autocomplete="off"
            />
            <gl-icon
              name="search"
              class="dropdown-input-search gl-absolute gl-top-3 gl-right-5 gl-text-gray-300 gl-pointer-events-none"
            />
            <gl-icon
              name="close"
              class="dropdown-input-clear js-dropdown-input-clear gl-right-5 gl-absolute gl-top-3 gl-text-gray-500"
            />
          </div>
          <div class="dropdown-content"></div>
          <div class="dropdown-loading"><gl-loading-icon size="sm" /></div>
        </div>
      </div>
    </div>
  </div>
</template>
