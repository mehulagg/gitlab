<script>
import { GlBadge, GlTable } from '@gitlab/ui';
import { kebabCase } from 'lodash';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import sprintf from '~/locale/sprintf';
import { detailsLabels, subscriptionTable, subscriptionTypeText } from '../constants';

const DEFAULT_BORDER_CLASSES = 'gl-border-b-1! gl-border-b-gray-100! gl-border-b-solid!';
const DEFAULT_TH_CLASSES = 'gl-bg-white! gl-border-t-0! gl-pb-5! gl-px-5! gl-text-gray-700!';
const DEFAULT_TD_CLASSES = 'gl-py-5!';
const tdAttr = (_, key) => ({ 'data-testid': `subscription-cell-${kebabCase(key)}` });
const tdClassBase = [DEFAULT_BORDER_CLASSES, DEFAULT_TD_CLASSES];
const tdClassHighlight = [...tdClassBase, 'gl-bg-blue-50!'];
const thClass = [DEFAULT_BORDER_CLASSES, DEFAULT_TH_CLASSES];

export default {
  i18n: {
    subscriptionHistoryTitle: subscriptionTable.title,
  },
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
  data() {
    return {
      fields: [
        {
          key: 'name',
          label: detailsLabels.name,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'email',
          label: detailsLabels.email,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'company',
          label: detailsLabels.company,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'plan',
          label: detailsLabels.plan,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'startsAt',
          label: subscriptionTable.activatedOn,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'validFrom',
          label: subscriptionTable.validFrom,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'expiresAt',
          label: subscriptionTable.expiresOn,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'usersInLicense',
          label: subscriptionTable.seats,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
        {
          key: 'type',
          label: subscriptionTable.type,
          tdAttr,
          tdClass: this.cellClass,
          thClass,
        },
      ],
    };
  },
  methods: {
    cellClass(_, x, item) {
      return item.id === this.currentSubscriptionId ? tdClassHighlight : tdClassBase;
    },
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
      :fields="fields"
      :items="subscriptionList"
      :tbody-tr-attr="rowAttr"
      :tbody-tr-class="rowClass"
      responsive
      stacked="sm"
    >
      <template #cell(type)="{ item }">
        <gl-badge size="md" variant="info">{{ getType(item.type) }}</gl-badge>
      </template>
    </gl-table>
  </section>
</template>
