<script>
import { mapState, mapGetters } from 'vuex';
import { s__ } from '~/locale';
import formattingMixins from '../../formatting_mixins';

export default {
  mixins: [formattingMixins],
  computed: {
    ...mapState(['startDate', 'taxRate', 'numberOfUsers']),
    ...mapGetters([
      'selectedPlanText',
      'selectedPlanPrice',
      'endDate',
      'totalExVat',
      'vat',
      'totalAmount',
      'usersPresent',
    ]),
  },
  i18n: {
    selectedPlanText: s__('Checkout|%{selectedPlanText} plan'),
    numberOfUsers: s__('Checkout|(x%{numberOfUsers})'),
    pricePerUserPerYear: s__('Checkout|$%{selectedPlanPrice} per user per year'),
    dates: s__('Checkout|%{startDate} - %{endDate}'),
    subtotal: s__('Checkout|Subtotal'),
    tax: s__('Checkout|Tax'),
    total: s__('Checkout|Total'),
  },
};
</script>
<template>
  <div>
    <div class="d-flex justify-content-between bold gl-mt-3 gl-mb-3">
      <div class="js-selected-plan">
        {{ sprintf($options.i18n.selectedPlanText, { selectedPlanText }) }}
        <span v-if="usersPresent" class="js-number-of-users">{{
          sprintf($options.i18n.numberOfUsers, { numberOfUsers })
        }}</span>
      </div>
      <div class="js-amount">{{ formatAmount(totalExVat, usersPresent) }}</div>
    </div>
    <div class="text-secondary js-per-user">
      {{
        sprintf($options.i18n.pricePerUserPerYear, {
          selectedPlanPrice: selectedPlanPrice.toLocaleString(),
        })
      }}
    </div>
    <div class="text-secondary js-dates">
      {{
        sprintf($options.i18n.dates, {
          startDate: formatDate(startDate),
          endDate: formatDate(endDate),
        })
      }}
    </div>
    <div v-if="taxRate">
      <div class="border-bottom gl-mt-3 gl-mb-3"></div>
      <div class="d-flex justify-content-between text-secondary">
        <div>{{ $options.i18n.subtotal }}</div>
        <div class="js-total-ex-vat">{{ formatAmount(totalExVat, usersPresent) }}</div>
      </div>
      <div class="d-flex justify-content-between text-secondary">
        <div>{{ $options.i18n.tax }}</div>
        <div class="js-vat">{{ formatAmount(vat, usersPresent) }}</div>
      </div>
    </div>
    <div class="border-bottom gl-mt-3 gl-mb-3"></div>
    <div class="d-flex justify-content-between bold gl-font-lg">
      <div>{{ $options.i18n.total }}</div>
      <div class="js-total-amount">{{ formatAmount(totalAmount, usersPresent) }}</div>
    </div>
  </div>
</template>
