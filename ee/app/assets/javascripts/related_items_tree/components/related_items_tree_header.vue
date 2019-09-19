<script>
import { mapState, mapGetters, mapActions } from 'vuex';

import { GlButton, GlTooltipDirective } from '@gitlab/ui';

import { sprintf, s__ } from '~/locale';

import Icon from '~/vue_shared/components/icon.vue';
import DroplabDropdownButton from '~/vue_shared/components/droplab_dropdown_button.vue';

import { EpicDropdownActions, ActionType } from '../constants';

export default {
  EpicDropdownActions,
  ActionType,
  components: {
    Icon,
    GlButton,
    DroplabDropdownButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  computed: {
    ...mapGetters(['headerItems']),
    ...mapState(['parentItem']),
    badgeTooltip() {
      return sprintf(s__('Epics|%{epicsCount} epics and %{issuesCount} issues'), {
        epicsCount: this.headerItems[0].count,
        issuesCount: this.headerItems[1].count,
      });
    },
  },
  methods: {
    ...mapActions(['toggleAddItemForm', 'toggleCreateEpicForm']),
    handleActionClick({ id, actionType }) {
      if (id === 0) {
        this.toggleAddItemForm({
          actionType,
          toggleState: true,
        });
      } else {
        this.toggleCreateEpicForm({
          actionType,
          toggleState: true,
        });
      }
    },
  },
};
</script>

<template>
  <div class="card-header d-flex px-2">
    <div class="d-inline-flex flex-grow-1 lh-100 align-middle">
      <div
        v-gl-tooltip.hover:tooltipcontainer.bottom
        class="issue-count-badge"
        :title="badgeTooltip"
      >
        <span
          v-for="(item, index) in headerItems"
          :key="index"
          :class="{ 'ml-2': index }"
          class="d-inline-flex align-items-center"
        >
          <icon :size="16" :name="item.iconName" css-classes="text-secondary mr-1" />
          {{ item.count }}
        </span>
      </div>
    </div>
    <div class="d-inline-flex">
      <template v-if="parentItem.userPermissions.adminEpic">
        <droplab-dropdown-button
          :actions="$options.EpicDropdownActions"
          :default-action="0"
          :primary-button-class="`${headerItems[0].qaClass} js-add-epics-button`"
          class="btn-create-epic"
          size="sm"
          @onActionClick="handleActionClick"
        />
        <gl-button
          :class="headerItems[1].qaClass"
          class="ml-1 js-add-issues-button"
          size="sm"
          @click="handleActionClick({ id: 0, actionType: 'issue' })"
          >{{ __('Add an issue') }}</gl-button
        >
      </template>
    </div>
  </div>
</template>
