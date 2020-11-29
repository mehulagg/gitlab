<script>
import { GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { s__ } from '~/locale';

export default {
  name: 'LdapDropdownItem',
  components: { GlDropdownItem, GlDropdownDivider },
  props: {
    memberId: {
      type: Number,
      required: true,
    },
  },
  methods: {
    ...mapActions(['updateLdapOverride']),
    handleClick() {
      this.updateLdapOverride({ memberId: this.memberId, override: false })
        .then(() => {
          this.$toast.show(s__('Members|Reverted to LDAP group sync settings.'));
        })
        .catch(() => {
          // Do nothing, error handled in `updateLdapOverride` Vuex action
        });
    },
  },
};
</script>

<template>
  <span>
    <gl-dropdown-divider />
    <gl-dropdown-item is-check-item @click="handleClick">
      {{ s__('Members|Revert to LDAP group sync settings') }}
    </gl-dropdown-item>
  </span>
</template>
