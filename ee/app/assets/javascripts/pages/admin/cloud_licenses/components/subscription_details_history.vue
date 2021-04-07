<script>
import { GlBadge, GlTable } from '@gitlab/ui';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import sprintf from '~/locale/sprintf';
import { detailsLabels, subscriptionTable, subscriptionTypeText } from '../constants';

const realSlugify = (data) => data.replace(/([A-Z])/g, (letter) => `-${letter.toLowerCase()}`);

const DEFAULT_BORDER_CLASSES = 'gl-border-b-1! gl-border-b-gray-100! gl-border-b-solid!';
const DEFAULT_TH_CLASSES = 'gl-bg-white! gl-border-t-0! gl-pb-5! gl-px-5! gl-text-gray-700!';
const DEFAULT_TD_CLASSES = 'gl-py-5!';
const tdAttr = (_, key) => ({ 'data-testid': `subscription-cell-${realSlugify(key)}` });
const tdClass = [DEFAULT_BORDER_CLASSES, DEFAULT_TD_CLASSES];
const thClass = [DEFAULT_BORDER_CLASSES, DEFAULT_TH_CLASSES];

export default {
  i18n: {
    subscriptionHistoryTitle: subscriptionTable.title,
  },
  fields: [
    {
      key: 'name',
      label: detailsLabels.name,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'email',
      label: detailsLabels.email,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'company',
      label: detailsLabels.company,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'plan',
      label: detailsLabels.plan,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'startsAt',
      label: subscriptionTable.activatedOn,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'validFrom',
      label: subscriptionTable.validFrom,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'expiresAt',
      label: subscriptionTable.expiresOn,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'usersInLicense',
      label: subscriptionTable.seats,
      tdAttr,
      tdClass,
      thClass,
    },
    {
      key: 'type',
      label: subscriptionTable.type,
      tdAttr,
      tdClass,
      thClass,
    },
  ],
  name: 'SubscriptionDetailsHistory',
  components: {
    GlBadge,
    GlTable,
  },
  props: {
    currentSubscriptionId: {
      type: String,
      required: false,
      default: null,
    },
    subscriptionList: {
      type: Array,
      required: true,
    },
  },
  methods: {
    getType(type) {
      return sprintf(subscriptionTypeText, { type: capitalizeFirstCharacter(type) });
    },
    rowAttr() {
      return {
        'data-testid': 'subscription-history-row',
      };
    },
    rowClass(item) {
      return item.id === this.currentSubscriptionId ? 'gl-font-weight-bold gl-text-blue-500' : '';
    },
  },
};
</script>

<template>
  <section>
    <header>
      <h2 class="gl-mb-6 gl-mt-0">{{ $options.i18n.subscriptionHistoryTitle }}</h2>
    </header>
    <gl-table
      :details-td-class="$options.tdClass"
      :fields="$options.fields"
      :items="subscriptionList"
      :tbody-tr-attr="rowAttr"
      :tbody-tr-class="rowClass"
      responsive
      stacked="sm"
    >
      <template #cell(type)="{ item }">
        <gl-badge class="gl-bg-blue-500! gl-text-white!" size="md" variant="info"
          >{{ getType(item.type) }}
        </gl-badge>
      </template>
    </gl-table>
  </section>
</template>
