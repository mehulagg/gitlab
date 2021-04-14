<script>
import { GlTable, GlBadge } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { __ } from '~/locale';
import { formatDate } from '~/lib/utils/datetime_utility';
import { DETAILS_FIELDS } from '../constants';

export default {
  name: 'SubscriptionSeatDetails',
  components: {
    GlBadge,
    GlTable,
  },
  props: {
    seatMemberId: {
      type: Number,
      required: true
    },
  },
  computed: {
    state() {
      return this.$store.getters.membershipsById(this.seatMemberId);
    },
    items() {
      return this.state.items;
    },
    isLoading() {
      return this.state.isLoading;
    }
  },
  created() {
    this.fetchBillableMemberDetails(this.seatMemberId);
  },
  methods: {
    ...mapActions([
      'fetchBillableMemberDetails',
    ]),
    formatDate,
  },
  fields: DETAILS_FIELDS,
};
</script>

<template>
  <gl-table :fields="$options.fields" :items="items" :busy="isLoading" data-testid="seat-usage-details">
    <template #cell(created_at)="{ item }">
      <span>{{ formatDate(item.created_at, 'yyyy-mm-dd') }}</span>
    </template>
    <template #cell(expires_at)="{ item }">
      <span>{{ item.expires_at ? item.expires_at : __('Never') }}</span>
    </template>
    <template #cell(role)="{ item }">
      <gl-badge>{{ item.access_level.string_value }}</gl-badge>
    </template>
  </gl-table>
</template>
