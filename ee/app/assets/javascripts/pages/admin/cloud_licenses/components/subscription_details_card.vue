<script>
import { GlCard } from '@gitlab/ui';
import { detailsLabels } from '../constants';
import SubscriptionDetailsTable from './subscription_details_table.vue';

export default {
  name: 'SubscriptionDetailsCard',
  components: {
    SubscriptionDetailsTable,
    GlCard,
  },
  props: {
    detailsFields: {
      type: Array,
      required: true,
    },
    headerText: {
      type: String,
      required: false,
      default: '',
    },
    subscription: {
      type: Object,
      required: true,
    },
  },
  computed: {
    details() {
      return this.detailsFields.map((detail) => ({
        canCopy: detail === 'id',
        label: detailsLabels[detail],
        value: this.subscription[detail],
      }));
    },
  },
};
</script>

<template>
  <gl-card>
    <template v-if="headerText" #header>
      <h6 class="gl-m-0">{{ headerText }}</h6>
    </template>

    <subscription-details-table :details="details" />

    <template #footer>
      <slot name="footer"></slot>
    </template>
  </gl-card>
</template>
