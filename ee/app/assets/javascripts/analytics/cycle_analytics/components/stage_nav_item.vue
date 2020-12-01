<script>
import { GlIcon, GlTooltipDirective, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { __ } from '~/locale';
import { approximateDuration } from '~/lib/utils/datetime_utility';
import StageCardListItem from './stage_card_list_item.vue';

const ERROR_MESSAGES = {
  tooMuchData: __('There is too much data to calculate. Please change your selection.'),
};

const ERROR_NAV_ITEM_CONTENT = {
  [ERROR_MESSAGES.tooMuchData]: __('Too much data'),
  fallback: __('Not enough data'),
};

export default {
  name: 'StageNavItem',
  components: {
    StageCardListItem,
    GlIcon,
    GlDropdown,
    GlDropdownItem,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isDefaultStage: {
      type: Boolean,
      default: false,
      required: false,
    },
    isActive: {
      type: Boolean,
      default: false,
      required: false,
    },
    title: {
      type: String,
      required: true,
    },
    value: {
      type: Number,
      default: 0,
      required: false,
    },
    id: {
      // The IDs of stages are strings until custom stages have been added.
      // Only at this point the IDs become numbers, so we have to allow both.
      type: [String, Number],
      required: true,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isHover: false,
      isTitleOverflowing: false,
    };
  },
  computed: {
    hasValue() {
      return this.value;
    },
    median() {
      return approximateDuration(this.value);
    },
    openMenuClasses() {
      return this.isHover ? 'gl-display-flex gl-justify-content-end' : '';
    },
    error() {
      return ERROR_NAV_ITEM_CONTENT[this.errorMessage] || ERROR_NAV_ITEM_CONTENT.fallback;
    },
    stageTitleTooltip() {
      return this.isTitleOverflowing ? this.title : null;
    },
  },
  mounted() {
    this.checkIfTitleOverflows();
  },
  updated() {
    this.checkIfTitleOverflows();
  },
  methods: {
    handleDropdownAction(action) {
      this.$emit(action);
    },
    handleSelectStage(e) {
      // we don't want to emit the select event when we click the more actions dropdown
      // But we should still trigger the event if we click anywhere else in the list item
      if (this.$refs.dropdown && !this.$refs.dropdown.contains(e.target)) {
        this.$emit('select');
      }
    },
    handleHover(hoverState = false) {
      this.isHover = hoverState;
    },
    checkIfTitleOverflows() {
      const [titleEl] = this.$refs.title?.children;
      if (titleEl) {
        this.isTitleOverflowing = titleEl.scrollWidth > this.$refs.title.offsetWidth;
      }
    },
  },
};
</script>

<template>
  <li
    :data-id="id"
    @click="handleSelectStage"
    @mouseover="handleHover(true)"
    @mouseleave="handleHover()"
  >
    <stage-card-list-item :is-active="isActive" class="gl-display-flex gl-justify-space-between">
      <div
        ref="title"
        class="stage-nav-item-cell stage-name text-truncate w-50 pr-2"
        :class="{ 'font-weight-bold': isActive }"
      >
        <span v-gl-tooltip="{ title: stageTitleTooltip }" data-testid="stage-title">{{
          title
        }}</span>
      </div>
      <div class="stage-nav-item-cell w-50 gl-display-flex gl-justify-content-between">
        <div ref="median" class="stage-median w-75 align-items-start">
          <span v-if="hasValue">{{ median }}</span>
          <span v-else v-gl-tooltip="{ title: errorMessage }" class="stage-empty">{{ error }}</span>
        </div>
        <div v-show="isHover" ref="dropdown" :class="[openMenuClasses]" class="dropdown w-25">
          <gl-dropdown
            toggle-class="gl-p-0! gl-bg-transparent! gl-shadow-none!"
            data-testid="more-actions-toggle"
          >
            <template #button-content>
              <span
                v-gl-tooltip
                category="tertiary"
                :title="__('More actions')"
                data-toggle="dropdown"
              >
                <gl-icon name="ellipsis_v" />
              </span>
            </template>
            <template v-if="isDefaultStage">
              <gl-dropdown-item
                category="tertiary"
                data-testid="hide-btn"
                @click="handleDropdownAction('hide', $event)"
              >
                {{ __('Hide stage') }}
              </gl-dropdown-item>
            </template>
            <template v-else>
              <gl-dropdown-item
                category="tertiary"
                data-testid="edit-btn"
                @click="handleDropdownAction('edit', $event)"
              >
                {{ __('Edit stage') }}
              </gl-dropdown-item>
              <gl-dropdown-item
                category="tertiary"
                data-testid="remove-btn"
                @click="handleDropdownAction('remove', $event)"
              >
                {{ __('Remove stage') }}
              </gl-dropdown-item>
            </template>
          </gl-dropdown>
        </div>
      </div>
    </stage-card-list-item>
  </li>
</template>
