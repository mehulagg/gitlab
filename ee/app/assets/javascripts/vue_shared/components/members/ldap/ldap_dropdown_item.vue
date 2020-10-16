<script>
import { GlDropdownItem } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { s__ } from '~/locale';

export default {
  name: 'LdapDropdownItem',
  components: { GlDropdownItem },
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
        .catch(() => {});
    },
  },
};
</script>

<template>
  <gl-dropdown-item is-check-item @click="handleClick">
    {{ s__('Members|Revert to LDAP group sync settings') }}
  </gl-dropdown-item>
</template>
