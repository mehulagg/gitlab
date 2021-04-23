<script>
import { GlCard } from '@gitlab/ui';
import { identity } from 'lodash';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { formatDate, getTimeago } from '~/lib/utils/datetime_utility';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import { detailsLabels } from '../constants';
import SubscriptionDetailsTable from './subscription_details_table.vue';

const humanReadableDate = (value) => (value ? formatDate(value, 'd mmmm yyyy') : '');

const subscriptionDetailsFormatRules = {
  id: getIdFromGraphQLId,
  expiresAt: getTimeago().format,
  lastSync: getTimeago().format,
  plan: capitalizeFirstCharacter,
  startsAt: humanReadableDate,
};

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
      return this.detailsFields.map((detail) => {
        const label = detailsLabels[detail];
        const formatter = subscriptionDetailsFormatRules[detail] || identity;
        const valueToFormat = this.subscription[detail];
        const value = valueToFormat ? formatter(valueToFormat) : '';
        return { canCopy: detail === 'id', label, value };
      });
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
