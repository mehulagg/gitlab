<script>
import { GlButton, GlCard, GlFormGroup, GlDropdown, GlDropdownItem } from '@gitlab/ui';

export default {
  name: 'OnDemandScansProfileSelector',
  components: {
    GlButton,
    GlCard,
    GlFormGroup,
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    libraryPath: {
      type: String,
      required: true,
    },
    newProfilePath: {
      type: String,
      required: true,
    },
    profiles: {
      type: Array,
      required: false,
      default: () => [],
    },
    value: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    selectedProfile() {
      return this.value ? this.profiles.find(({ id }) => this.value === id) : null;
    },
  },
};
</script>

<template>
  <gl-card>
    <template #header>
      <div class="row">
        <div class="col-7 gl-display-flex gl-align-items-center">
          <h3 class="gl-font-lg gl-my-0">
            <slot name="title"></slot>
          </h3>
        </div>
        <div class="col-5 gl-text-right">
          <gl-button
            :href="profiles.length ? libraryPath : null"
            :disabled="!profiles.length"
            variant="success"
            category="secondary"
            size="small"
            data-testid="manage-profiles-link"
          >
            {{ s__('OnDemandScans|Manage profiles') }}
          </gl-button>
        </div>
      </div>
    </template>
    <gl-form-group v-if="profiles.length">
      <template #label>
        <slot name="label"></slot>
      </template>
      <gl-dropdown
        :text="
          selectedProfile
            ? selectedProfile.dropdownLabel
            : s__('OnDemandScans|Select one of the existing profiles')
        "
        class="mw-460"
        data-testid="profiles-dropdown"
      >
        <gl-dropdown-item
          v-for="profile in profiles"
          :key="profile.id"
          :is-checked="value === profile.id"
          is-check-item
          @click="$emit('input', profile.id)"
        >
          {{ profile.profileName }}
        </gl-dropdown-item>
      </gl-dropdown>
      <div
        v-if="value && $scopedSlots.summary"
        data-testid="selected-profile-summary"
        class="gl-mt-6 gl-pt-6 gl-border-t-solid gl-border-gray-100 gl-border-t-1"
      >
        <slot name="summary"></slot>
      </div>
    </gl-form-group>
    <template v-else>
      <p class="gl-text-gray-700">
        <slot name="no-profiles"></slot>
      </p>
      <gl-button
        :href="newProfilePath"
        variant="success"
        category="secondary"
        data-testid="create-profile-link"
      >
        <slot name="new-profile"></slot>
      </gl-button>
    </template>
  </gl-card>
</template>
