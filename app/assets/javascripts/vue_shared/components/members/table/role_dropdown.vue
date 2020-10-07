<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';

export default {
  name: 'RoleDropdown',
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      selectedRole: this.member.accessLevel,
    };
  },
  computed: {
    isDesktop() {
      return bp.isDesktop();
    },
  },
  methods: {
    handleSelect(integerValue, stringValue) {
      if (integerValue === this.selectedRole.integerValue) {
        return;
      }

      this.selectedRole = { integerValue, stringValue };
    },
  },
};
</script>

<template>
  <gl-dropdown
    :right="!isDesktop"
    :text="selectedRole.stringValue"
    :header-text="__('Change permissions')"
  >
    <gl-dropdown-item
      v-for="(value, name) in member.validRoles"
      :key="value"
      @click="handleSelect(value, name)"
    >
      {{ name }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
