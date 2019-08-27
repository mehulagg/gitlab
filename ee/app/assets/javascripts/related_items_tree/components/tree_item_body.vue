<script>
import { mapState, mapActions } from 'vuex';
import { GlTooltipDirective, GlModalDirective, GlLink, GlButton } from '@gitlab/ui';
import _ from 'lodash-es';

import { __ } from '~/locale';

import Icon from '~/vue_shared/components/icon.vue';
import ItemMilestone from '~/vue_shared/components/issue/issue_milestone.vue';
import ItemAssignees from '~/vue_shared/components/issue/issue_assignees.vue';
import ItemDueDate from '~/boards/components/issue_due_date.vue';
import ItemWeight from 'ee/boards/components/issue_card_weight.vue';

import StateTooltip from './state_tooltip.vue';

import { ChildType, ChildState, itemRemoveModalId } from '../constants';

export default {
  itemRemoveModalId,
  components: {
    Icon,
    GlLink,
    GlButton,
    StateTooltip,
    ItemMilestone,
    ItemAssignees,
    ItemDueDate,
    ItemWeight,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModalDirective,
  },
  props: {
    parentItem: {
      type: Object,
      required: true,
    },
    item: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState(['childrenFlags']),
    itemReference() {
      return this.item.reference;
    },
    itemWebPath() {
      // Here, GraphQL API (during item fetch) returns `webPath`
      // and Rails API (during item add) returns `path`,
      // we need to make both accessible.
      return this.item.path || this.item.webPath;
    },
    isOpen() {
      return this.item.state === ChildState.Open;
    },
    isClosed() {
      return this.item.state === ChildState.Closed;
    },
    hasMilestone() {
      return !_.isEmpty(this.item.milestone);
    },
    hasAssignees() {
      return this.item.assignees && this.item.assignees.length > 0;
    },
    stateText() {
      return this.isOpen ? __('Opened') : __('Closed');
    },
    stateIconName() {
      return this.item.type === ChildType.Epic ? 'epic' : 'issues';
    },
    stateIconClass() {
      return this.isOpen ? 'issue-token-state-icon-open' : 'issue-token-state-icon-closed';
    },
    itemPath() {
      return this.itemReference.split(this.item.pathIdSeparator)[0];
    },
    itemId() {
      return this.itemReference.split(this.item.pathIdSeparator).pop();
    },
    computedPath() {
      return this.itemWebPath.length ? this.itemWebPath : null;
    },
    itemActionInProgress() {
      return (
        this.childrenFlags[this.itemReference].itemChildrenFetchInProgress ||
        this.childrenFlags[this.itemReference].itemRemoveInProgress
      );
    },
  },
  methods: {
    ...mapActions(['setRemoveItemModalProps']),
    handleRemoveClick() {
      const { parentItem, item } = this;

      this.setRemoveItemModalProps({
        parentItem,
        item,
      });
    },
  },
};
</script>

<template>
  <div class="card card-slim sortable-row flex-grow-1">
    <div class="item-body card-body d-flex align-items-center p-2 p-xl-1 pl-xl-3">
      <div class="item-contents d-flex align-items-center flex-wrap flex-grow-1 flex-xl-nowrap">
        <div class="item-title d-flex align-items-center mb-1 mb-xl-0">
          <icon
            ref="stateIconLg"
            :css-classes="stateIconClass"
            :name="stateIconName"
            :size="16"
            :aria-label="stateText"
          />
          <state-tooltip
            :get-target-ref="() => $refs.stateIconLg"
            :is-open="isOpen"
            :state="item.state"
            :created-at="item.createdAt"
            :closed-at="item.closedAt || ''"
          />
          <icon
            v-if="item.confidential"
            v-gl-tooltip.hover
            :size="16"
            :title="__('Confidential')"
            :aria-label="__('Confidential')"
            name="eye-slash"
            css-classes="confidential-icon append-right-4 align-self-baseline align-self-md-auto mt-xl-0"
          />
          <gl-link :href="computedPath" class="sortable-link">{{ item.title }}</gl-link>
        </div>
        <div class="item-meta d-flex flex-wrap mt-xl-0 justify-content-xl-end flex-xl-nowrap">
          <div
            class="d-flex align-items-center item-path-id order-md-0 mt-md-0 mt-1 ml-xl-2 mr-xl-auto"
          >
            <icon
              ref="stateIconMd"
              :css-classes="stateIconClass"
              :name="stateIconName"
              :size="16"
              :aria-label="stateText"
              class="d-xl-none"
            />
            <state-tooltip
              :get-target-ref="() => $refs.stateIconMd"
              :is-open="isOpen"
              :state="item.state"
              :created-at="item.createdAt"
              :closed-at="item.closedAt || ''"
            />
            <span v-gl-tooltip :title="itemPath" class="path-id-text d-inline-block">{{
              itemPath
            }}</span
            >{{ item.pathIdSeparator }}{{ itemId }}
          </div>
          <div
            class="item-meta-child d-flex align-items-center order-0 flex-wrap mr-md-1 ml-md-auto ml-xl-2 flex-xl-nowrap"
          >
            <item-milestone
              v-if="hasMilestone"
              :milestone="item.milestone"
              class="d-flex align-items-center item-milestone"
            />
            <item-due-date
              v-if="item.dueDate"
              :date="item.dueDate"
              tooltip-placement="top"
              css-class="item-due-date d-flex align-items-center ml-2 mr-0"
            />
            <item-weight
              v-if="item.weight"
              :weight="item.weight"
              class="item-weight d-flex align-items-center ml-2 mr-0"
              tag-name="span"
            />
          </div>
          <item-assignees
            v-if="hasAssignees"
            :assignees="item.assignees"
            class="item-assignees d-inline-flex align-items-center align-self-end ml-auto ml-md-0 mb-md-0 order-2 flex-xl-grow-0 mt-xl-0 mr-xl-1"
          />
        </div>
        <gl-button
          v-if="parentItem.userPermissions.adminEpic"
          v-gl-tooltip.hover
          v-gl-modal-directive="$options.itemRemoveModalId"
          :title="__('Remove')"
          :disabled="itemActionInProgress"
          class="btn-svg btn-item-remove js-issue-item-remove-button qa-remove-issue-button"
          @click="handleRemoveClick"
        >
          <icon :size="16" name="close" css-classes="btn-item-remove-icon" />
        </gl-button>
        <span v-if="!parentItem.userPermissions.adminEpic" class="p-3"></span>
      </div>
    </div>
  </div>
</template>
