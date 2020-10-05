<script>
import { GlSprintf } from '@gitlab/ui';
import { mapState } from 'vuex';
import { sprintf, s__ } from '~/locale';
import Step from './step.vue';
import Zuora from './zuora.vue';

export default {
  components: {
    GlSprintf,
    Step,
    Zuora,
  },
  computed: {
    ...mapState(['paymentMethodId', 'creditCardDetails']),
    isValid() {
      return Boolean(this.paymentMethodId);
    },
    expirationDate() {
      return sprintf(this.$options.i18n.expirationDate, {
        expirationMonth: this.creditCardDetails.credit_card_expiration_month,
        expirationYear: this.creditCardDetails.credit_card_expiration_year.toString(10).slice(-2),
      });
    },
  },
  i18n: {
    stepTitle: s__('Checkout|Payment method'),
    creditCardDetails: s__('Checkout|%{cardType} ending in %{lastFourDigits}'),
    expirationDate: s__('Checkout|Exp %{expirationMonth}/%{expirationYear}'),
  },
};
</script>
<template>
  <step step="paymentMethod" :title="$options.i18n.stepTitle" :is-valid="isValid">
    <template #body="props">
      <zuora :active="props.active" />
    </template>
    <template #summary>
      <div class="js-summary-line-1">
        <gl-sprintf :message="$options.i18n.creditCardDetails">
          <template #cardType>
            {{ creditCardDetails.credit_card_type }}
          </template>
          <template #lastFourDigits>
            <strong>{{ creditCardDetails.credit_card_mask_number.slice(-4) }}</strong>
          </template>
        </gl-sprintf>
      </div>
      <div class="js-summary-line-2">
        {{ expirationDate }}
      </div>
    </template>
  </step>
</template>
