<script>
import { mapState, mapActions } from 'vuex';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import { __ } from '~/locale';
import LicenseCardBody from './license_card_body.vue';

export default {
  name: 'LicenseCard',
  components: {
    LicenseCardBody,
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    license: {
      type: Object,
      required: false,
      default() {
        return { licensee: {} };
      },
    },
    isCurrentLicense: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState(['activeUserCount', 'guestUserCount', 'deleteQueue', 'downloadLicensePath']),
    isRemoving() {
      return this.deleteQueue.includes(this.license.id);
    },
  },
  methods: {
    ...mapActions(['fetchDeleteLicense']),
    capitalizeFirstCharacter,
    confirmDeleteLicense(...args) {
      window.confirm(__('Are you sure you want to permanently delete this license?')); // eslint-disable-line no-alert
      this.fetchDeleteLicense(...args);
    },
  },
};
</script>

<template>
  <div class="card license-card mb-5">
    <div class="card-header">
      <div class="d-flex justify-content-between align-items-center">
        <h4>
          {{
            sprintf(__('GitLab Enterprise Edition %{plan}'), {
              plan: capitalizeFirstCharacter(license.plan),
            })
          }}
        </h4>

        <gl-dropdown right class="js-manage-license" :text="__('Manage')" :disabled="isRemoving">
          <gl-dropdown-item
            v-if="isCurrentLicense"
            class="js-download-license"
            :href="downloadLicensePath"
          >
            {{ __('Download license') }}
          </gl-dropdown-item>
          <gl-dropdown-item
            class="js-delete-license text-danger"
            @click="confirmDeleteLicense(license)"
          >
            {{ __('Delete license') }}
          </gl-dropdown-item>
        </gl-dropdown>
      </div>
    </div>

    <license-card-body
      :license="license"
      :is-removing="isRemoving"
      :active-user-count="activeUserCount"
      :guest-user-count="guestUserCount"
    />
  </div>
</template>
