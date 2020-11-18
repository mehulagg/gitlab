<script>
  import {GlModal, GlForm, GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem} from '@gitlab/ui';
  import {s__, __} from '~/locale';

  export default {
    components: {GlModal, GlForm, GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem},
    actionsProps: {
      primary: {
        text: s__('OnCallSchedules|Add schedule'),
        attributes: [
          {variant: 'info'},
        ]
      },
      cancel: {
        text: __('Cancel')
      }
    },
    props: {
      modalId: {
        type: String,
        required: true,
      },
    },
    data() {
      return {
        alert: null,
        loading: false,
        form: {},
      };
    },
    computed: {
      okButtonText() {
        return this.loading ? s__('Metrics|Duplicating...') : s__('Metrics|Duplicate');
      },
    },
    methods: {

      hide() {
        this.alert = null;
      },
      formChange(form) {
        this.form = form;
      },
    },
  };
</script>

<template>
  <gl-modal
    :modal-id="modalId"
    size="sm"
    :title="s__('OnCallSchedules|Add schedule')"
    :action-primary="$options.actionsProps.primary"
    :action-cancel="$options.actionsProps.cancel"
    @primary="ok"
  >
    <gl-form @submit="onSubmit" @reset="onReset">
      <gl-form-group
        :label="__('Name')"
        label-size="sm"
        label-for="schedule-name"
      >
        <gl-form-input id="schedule-name"/>
      </gl-form-group>

      <gl-form-group
        :label="__('Description')"
        label-size="sm"
        label-for="schedule-description"
      >
        <gl-form-input id="schedule-description"/>
      </gl-form-group>

      <gl-form-group
        :label="__('Timezone')"
        label-size="sm"
        :description="s__('OnCallSchedules|Sets the default timezone for the schedule, for all participants')"
        label-for="schedule-timezone"
      >
        <gl-dropdown text="Some dropdown" class="gl-w-full">
          <gl-dropdown-item v-for="tz in timezones">Name</gl-dropdown-item>
        </gl-dropdown>
        <gl-form-select id="schedule-timezone"/>
      </gl-form-group>
    </gl-form>
  </gl-modal>
</template>
