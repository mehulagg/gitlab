<script>
import { GlFormRadio } from '@gitlab/ui';
import { dateInWords, parsePikadayDate } from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import SidebarFormattedDate from './sidebar_formatted_date.vue';

export default {
  components: {
    GlFormRadio,
    SidebarFormattedDate,
  },
  inject: ['canUpdate'],
  props: {
    issuable: {
      required: true,
      type: Object,
    },
    formattedDate: {
      required: true,
      type: String,
    },
    resetAction: {
      required: true,
      type: Function,
    },
    isLoading: {
      required: true,
      type: Boolean,
    },
    setDate: {
      required: true,
      type: Function,
    },
  },
  computed: {
    dateIsFixed: {
      get() {
        return this.issuable?.dueDateIsFixed;
      },
      set(fixed) {
        this.setDate(this.issuable.dueDateFixed, fixed);
      },
    },
    hasFixedDate() {
      return this.issuable.dueDateFixed !== null;
    },
    hasInheritedDate() {
      return this.issuable.dueDateFromMilestones !== null;
    },
    formattedFixedDate() {
      const { dueDateFixed } = this.issuable;
      if (!dueDateFixed) {
        return this.$options.i18n.noDate;
      }

      return dateInWords(parsePikadayDate(dueDateFixed), true);
    },
    formattedInheritedDate() {
      const { dueDateFromMilestones } = this.issuable;
      if (!dueDateFromMilestones) {
        return this.$options.i18n.noDate;
      }

      return dateInWords(parsePikadayDate(dueDateFromMilestones), true);
    },
  },
  i18n: {
    fixed: __('Fixed:'),
    inherited: __('Inherited:'),
    remove: __('remove'),
    noDate: __('None'),
  },
};
</script>

<template>
  <div class="hide-collapsed">
    <div class="gl-display-flex gl-align-items-baseline">
      <gl-form-radio
        v-model="dateIsFixed"
        :value="true"
        :disabled="!canUpdate || isLoading"
        class="gl-pr-2"
      >
        <span :class="dateIsFixed ? 'gl-text-gray-900 gl-font-weight-bold' : 'gl-text-gray-500'">
          {{ $options.i18n.fixed }}
        </span>
      </gl-form-radio>
      <sidebar-formatted-date
        :has-date="dateIsFixed"
        :formatted-date="formattedFixedDate"
        :reset-action="resetAction"
        :reset-text="$options.i18n.remove"
        :is-loading="isLoading"
        :can-delete="dateIsFixed && hasFixedDate"
        class="gl-line-height-24"
      />
    </div>
    <div class="gl-display-flex gl-align-items-baseline">
      <gl-form-radio
        v-model="dateIsFixed"
        :value="false"
        :disabled="!canUpdate || isLoading"
        class="gl-pr-2"
      >
        <span :class="!dateIsFixed ? 'gl-text-gray-900 gl-font-weight-bold' : 'gl-text-gray-500'">
          {{ $options.i18n.inherited }}
        </span>
      </gl-form-radio>
      <sidebar-formatted-date
        :has-date="!dateIsFixed"
        :formatted-date="formattedInheritedDate"
        :reset-action="resetAction"
        :reset-text="$options.i18n.remove"
        :is-loading="isLoading"
        :can-delete="false"
        class="gl-line-height-24"
      />
    </div>
  </div>
</template>
