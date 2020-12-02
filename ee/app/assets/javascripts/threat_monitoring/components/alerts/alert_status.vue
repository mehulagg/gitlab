<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { s__ } from '~/locale';
// TODO once backend is settled, update by either abstracting this out to app/assets/javascripts/graphql_shared or create new, modified query in #287757
import updateAlertStatusMutation from '~/alert_management/graphql/mutations/update_alert_status.mutation.graphql';

export default {
  i18n: {
    updateError: s__('ThreatMonitoring|There was an error while updating the status of the alert.'),
    updateInstruction: s__('ThreatMonitoring|Please try again.'),
  },
  statuses: {
    TRIGGERED: s__('ThreatMonitoring|Unreviewed'),
    ACKNOWLEDGED: s__('ThreatMonitoring|In review'),
    RESOLVED: s__('ThreatMonitoring|Resolved'),
    IGNORED: s__('ThreatMonitoring|Dismissed'),
  },
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    alert: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isUpdating: false,
      status: this.alert.status,
    };
  },
  methods: {
    handleError() {
      this.$emit(
        'alert-error',
        `${this.$options.i18n.updateError} ${this.$options.i18n.updateInstruction}`,
      );
    },
    updateAlertStatus(status) {
      this.isUpdating = true;
      this.status = status;
      this.$apollo
        .mutate({
          mutation: updateAlertStatusMutation,
          variables: {
            iid: this.alert.iid,
            status: status.toUpperCase(),
            projectPath: this.projectPath,
          },
        })
        .then(resp => {
          const errors = resp.data?.updateAlertStatus?.errors || [];

          if (errors[0]) {
            this.handleError();
          }

          this.$emit('hide-dropdown');
        })
        .catch(() => {
          this.status = this.alert.status;
          this.handleError();
        })
        .finally(() => {
          this.isUpdating = false;
        });
    },
  },
};
</script>

<template>
  <div class="dropdown dropdown-menu-selectable">
    <gl-dropdown
      :loading="isUpdating"
      right
      :text="$options.statuses[status]"
      class="gl-w-full"
      toggle-class="dropdown-menu-toggle"
    >
      <div class="dropdown-content dropdown-body">
        <gl-dropdown-item
          v-for="(label, field) in $options.statuses"
          :key="field"
          :active="field === status"
          :active-class="'is-active'"
          @click="updateAlertStatus(field)"
        >
          {{ label }}
        </gl-dropdown-item>
      </div>
    </gl-dropdown>
  </div>
</template>
