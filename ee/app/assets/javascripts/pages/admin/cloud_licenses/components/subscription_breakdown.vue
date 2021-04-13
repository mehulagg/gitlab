<script>
import { GlButton } from '@gitlab/ui';
import {
  licensedToHeaderText,
  manageSubscriptionButtonText,
  subscriptionDetailsHeaderText,
  syncSubscriptionButtonText,
} from '../constants';
import SubscriptionDetailsCard from './subscription_details_card.vue';
import SubscriptionDetailsHistory from './subscription_details_history.vue';
import SubscriptionDetailsUserInfo from './subscription_details_user_info.vue';

export const subscriptionDetailsFields = ['id', 'plan', 'lastSync', 'startsAt', 'renews'];
export const licensedToFields = ['name', 'email', 'company'];

export default {
  i18n: {
    licensedToHeaderText,
    manageSubscriptionButtonText,
    subscriptionDetailsHeaderText,
    syncSubscriptionButtonText,
  },
  name: 'SubscriptionBreakdown',
  components: {
    SubscriptionDetailsHistory,
    GlButton,
    SubscriptionDetailsCard,
    SubscriptionDetailsUserInfo,
  },
  props: {
    subscription: {
      type: Object,
      required: true,
    },
    subscriptionList: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      subscriptionDetailsFields,
      licensedToFields,
    };
  },
  computed: {
    hasSubscription() {
      return Boolean(Object.keys(this.subscription).length);
    },
    hasSubscriptionHistory() {
      return Boolean(this.subscriptionList.length);
    },
    canMangeSubscription() {
      return false;
    },
  },
};
</script>

<template>
  <div>
    <section class="row gl-mb-5">
      <div class="col-md-6 gl-mb-5">
        <subscription-details-card
          :details-fields="subscriptionDetailsFields"
          :header-text="$options.i18n.subscriptionDetailsHeaderText"
          :subscription="subscription"
        >
          <template v-if="canMangeSubscription" #footer>
            <gl-button category="primary" variant="confirm">
              {{ $options.i18n.syncSubscriptionButtonText }}
            </gl-button>
            <gl-button>
              {{ $options.i18n.manageSubscriptionButtonText }}
            </gl-button>
          </template>
        </subscription-details-card>
      </div>

      <div class="col-md-6 gl-mb-5">
        <subscription-details-card
          :details-fields="licensedToFields"
          :header-text="$options.i18n.licensedToHeaderText"
          :subscription="subscription"
        />
      </div>
    </section>
    <subscription-details-user-info v-if="hasSubscription" :subscription="subscription" />
    <subscription-details-history
      v-if="hasSubscriptionHistory"
      :current-subscription-id="subscription.id"
      :subscription-list="subscriptionList"
    />
  </div>
</template>
