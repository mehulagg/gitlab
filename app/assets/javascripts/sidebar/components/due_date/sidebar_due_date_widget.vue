<script>
import { GlButton, GlIcon, GlDatepicker, GlTooltipDirective } from '@gitlab/ui';
import produce from 'immer';
import Vue from 'vue';
import createFlash from '~/flash';
import { dateInWords, formatDate, parsePikadayDate } from '~/lib/utils/datetime_utility';
import { __, sprintf } from '~/locale';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import { dueDateQueries } from '~/sidebar/constants';

export const dueDateWidget = Vue.observable({
  setDueDate: null,
});

const hideDropdownEvent = new CustomEvent('hiddenGlDropdown', {
  bubbles: true,
});

export default {
  tracking: {
    event: 'click_edit_button',
    label: 'right_sidebar',
    property: 'dueDate',
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlIcon,
    GlDatepicker,
    SidebarEditableItem,
  },
  inject: ['fullPath', 'iid'],
  props: {
    issuableType: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      dueDate: null,
    };
  },
  apollo: {
    dueDate: {
      query() {
        return dueDateQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
          iid: String(this.iid),
        };
      },
      update(data) {
        return data.workspace?.issuable?.dueDate || null;
      },
      result({ data }) {
        this.$emit('dueDateUpdated', data.workspace?.issuable?.dueDate);
      },
      error() {
        createFlash({
          message: sprintf(__('Something went wrong while setting %{issuableType} due date.'), {
            issuableType: this.issuableType,
          }),
        });
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.dueDate.loading;
    },
    hasDueDate() {
      return this.dueDate != null;
    },
    parsedDueDate() {
      if (!this.hasDueDate) {
        return null;
      }
      console.log('PARSED', this.dueDate);

      return parsePikadayDate(this.dueDate);
    },
    formattedDueDate() {
      if (!this.hasDueDate) {
        return this.$options.i18n.noDueDate;
      }

      return dateInWords(this.parsedDueDate, true);
    },
  },
  mounted() {
    dueDateWidget.setDueDate = this.setDueDate;
  },
  destroyed() {
    dueDateWidget.setDueDate = null;
  },
  methods: {
    closeForm() {
      this.$refs.editable.collapse();
      this.$el.dispatchEvent(hideDropdownEvent);
      this.$emit('closeForm');
    },
    // synchronizing the quick action with the sidebar widget
    // this is a temporary solution until we have dueDate real-time updates
    setDueDate(date) {
      const { defaultClient: client } = this.$apollo.provider.clients;
      const sourceData = client.readQuery({
        query: dueDateQueries[this.issuableType].query,
        variables: { fullPath: this.fullPath, iid: this.iid },
      });
      console.log('THIS', date);

      const data = produce(sourceData, (draftData) => {
        draftData.workspace.issuable.dueDate = date ? formatDate(date, 'yyyy-mm-dd') : null;
      });
      console.log('DATA', data);

      client.writeQuery({
        query: dueDateQueries[this.issuableType].query,
        variables: { fullPath: this.fullPath, iid: this.iid },
        data,
      });
    },
    expandSidebar() {
      this.$refs.editable.expand();
      this.$emit('expandSidebar');
    },
  },
  i18n: {
    dueDate: __('Due date'),
    noDueDate: __('None'),
    removeDueDate: __('remove due date'),
  },
};
</script>

<template>
  <sidebar-editable-item
    ref="editable"
    :title="$options.i18n.dueDate"
    :tracking="$options.tracking"
    :loading="isLoading"
    class="block due-date"
  >
    <template #collapsed>
      <div v-gl-tooltip :title="$options.i18n.dueDate" class="sidebar-collapsed-icon">
        <gl-icon :size="16" name="calendar" />
        <span class="collapse-truncated-title">{{ formattedDueDate }}</span>
      </div>
      <div v-if="hasDueDate" class="gl-display-flex gl-align-items-center hide-collapsed">
        <strong class="gl-text-gray-900">{{ formattedDueDate }}</strong>
        <span class="gl-mx-2">-</span>
        <gl-button
          variant="link"
          class="gl-text-gray-500!"
          data-testid="reset-button"
          :disabled="isLoading"
          @click="setDueDate(null)"
        >
          {{ $options.i18n.removeDueDate }}
        </gl-button>
      </div>
      <div v-else>
        <span class="gl-text-gray-500 hide-collapsed">{{ formattedDueDate }}</span>
      </div>
    </template>
    <template #default>
      <gl-datepicker
        ref="datePicker"
        :value="parsedDueDate"
        show-clear-button
        @input="setDueDate"
        @clear="setDueDate(null)"
      />
    </template>
  </sidebar-editable-item>
</template>
