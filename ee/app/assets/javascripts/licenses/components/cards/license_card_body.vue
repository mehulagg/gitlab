<script>
import { GlLink, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import { Cell, HeaderCell, InfoCell, DateCell } from '../cells';

export default {
  name: 'LicenseCardBody',
  components: {
    GlIcon,
    Cell,
    HeaderCell,
    InfoCell,
    DateCell,
    GlLink,
  },
  props: {
    license: {
      type: Object,
      required: false,
      default() {
        return {
          licensee: {},
        };
      },
    },
    isRemoving: {
      type: Boolean,
      required: false,
      default: false,
    },
    activeUserCount: {
      type: Number,
      required: true,
    },
    guestUserCount: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      info: {
        currentActiveUserCount: __(
          "Users with a Guest role or those who don't belong to any projects or groups don't count towards seats in use.",
        ),
        historicalMax: __(`This is the maximum number of users that have existed at the same time since the license started.
              This is the minimum number of seats you will need to buy when you renew your license.`),
        overage: __(`GitLab allows you to continue using your license even if you exceed the number of seats you purchased.
              You will be required to pay for these seats when you renew your license.`),
      },
    };
  },
  computed: {
    seatsInUseComponent() {
      return this.license.plan === 'ultimate' ? 'info-cell' : 'cell';
    },
    seatsInUseForThisLicense() {
      return this.license.plan === 'ultimate'
        ? this.activeUserCount - this.guestUserCount
        : this.activeUserCount;
    },
  },
  methods: {
    licenseeValue(key) {
      return this.license.licensee[key] || __('Unknown');
    },
  },

  emits: [],
};
</script>

<template>
  <div class="card-body license-card-body p-0">
    <div
      v-if="isRemoving"
      class="p-5 d-flex justify-content-center align-items-center license-card-loading"
    >
      <gl-icon name="spinner" /><span class="ml-2">{{ __('Removing license…') }}</span>
    </div>

    <div v-else class="license-table js-license-table">
      <div class="license-row d-flex">
        <header-cell :title="__('Usage')" icon="monitor" />
        <cell :title="__('Seats in license')" :value="license.userLimit || __('Unlimited')" />
        <component
          :is="seatsInUseComponent"
          :title="__('Seats currently in use')"
          :value="seatsInUseForThisLicense"
          :popover-content="info.currentActiveUserCount"
        />
        <info-cell
          :title="__('Max seats used')"
          :value="license.historicalMax"
          :popover-content="info.historicalMax"
        />
        <info-cell
          :title="__('Users outside of license')"
          :value="license.overage"
          :popover-content="info.overage"
        />
      </div>

      <div class="license-row d-flex">
        <header-cell :title="__('Validity')" icon="calendar" />
        <date-cell :title="__('Start date')" :value="license.startsAt" />
        <date-cell :title="__('End date')" :value="license.expiresAt" :is-expirable="true" />
        <date-cell :title="__('Uploaded on')" :value="license.createdAt" />
      </div>

      <div class="license-row d-flex">
        <header-cell :title="__('Registration')" icon="user" />
        <cell :title="__('Licensed to')" :value="licenseeValue('Name')" />
        <cell :title="__('Email address')" :value="licenseeValue('Email')" />
        <cell :title="__('Company')" :value="licenseeValue('Company')" />
      </div>
    </div>
  </div>
</template>
