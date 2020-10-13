<script>
import { GlIcon } from '@gitlab/ui';
import { dateInWords } from '~/lib/utils/datetime_utility';
import Popover from '~/vue_shared/components/help_popover.vue';

export default {
  name: 'SubscriptionTableRow',
  components: {
    GlIcon,
    Popover,
  },
  props: {
    header: {
      type: Object,
      required: true,
    },
    columns: {
      type: Array,
      required: true,
    },
    isFreePlan: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    getPopoverOptions(col) {
      const defaults = {
        placement: 'bottom',
      };
      return { ...defaults, ...col.popover };
    },
    getDisplayValue(col) {
      if (col.isDate && col.value) {
        const [year, month, day] = col.value.split('-');

        // create UTC date (prevent date from being converted to local timezone)
        return dateInWords(new Date(year, month - 1, day));
      }

      // let's display '-' instead of 0 for the 'Free' plan
      if (this.isFreePlan && col.value === 0) {
        return ' - ';
      }

      return typeof col.value !== 'undefined' && col.value !== null ? col.value : ' - ';
    },
  },
};
</script>

<template>
  <div class="grid-row d-flex flex-grow-1 flex-column flex-sm-column flex-md-column flex-lg-row">
    <div class="grid-cell header-cell">
      <span class="icon-wrapper">
        <gl-icon v-if="header.icon" class="gl-mr-3" :name="header.icon" aria-hidden="true" />
        {{ header.title }}
      </span>
    </div>
    <template v-for="(col, i) in columns">
      <div
        :key="`subscription-col-${i}`"
        class="grid-cell"
        :class="[col.hideContent ? 'no-value' : '']"
      >
        <span class="property-label"> {{ col.label }} </span>
        <popover v-if="col.popover" :options="getPopoverOptions(col)" />
        <p class="property-value gl-mt-2 gl-mb-0" :class="[col.colClass ? col.colClass : '']">
          {{ getDisplayValue(col) }}
        </p>
      </div>
    </template>
  </div>
</template>
