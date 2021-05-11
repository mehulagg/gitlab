<script>
import {
  GlIcon,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlSafeHtmlDirective as SafeHtml,
  GlCard,
} from '@gitlab/ui';
import { isEqual, isEmpty } from 'lodash';
import { s__, __ } from '~/locale';

export const i18n = {
  selectTimezone: s__('EscalationPolicies|Select timezone'),
  search: __('Search'),
  noResults: __('No matching results'),
  fields: {
    name: {
      title: __('Name'),
      validation: {
        empty: __("Can't be empty"),
      },
    },
    description: { title: __('Description (optional)') },
    rules: {
      title: s__('EscalationPolicies|Escalation rules'),
      validation: {
        empty: __("Can't be empty"),
      },
    },
  },
  errorMsg: s__('EscalationPolicies|Failed to add schedule'),
};

export default {
  i18n,
  components: {
    GlIcon,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlCard,
  },
  directives: {
    SafeHtml,
  },
  inject: ['projectPath'],
  props: {
    form: {
      type: Object,
      required: true,
    },
    validationState: {
      type: Object,
      required: true,
    },
    schedule: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      tzSearchTerm: '',
      selectedDropdownTimezone: null,
    };
  },
  computed: {

  },
  methods: {
    isTimezoneSelected(tz) {
      return isEqual(tz, this.form.timezone);
    },
    setTimezone(timezone) {
      this.selectedDropdownTimezone = timezone;
    },
  },
};
</script>

<template>
  <gl-form>
    <div class="w-75 gl-xs-w-full!">

      <gl-form-group
        :label="$options.i18n.fields.name.title"
        :invalid-feedback="$options.i18n.fields.name.validation.empty"
        label-size="sm"
        label-for="schedule-name"
        :state="validationState.name"
        requried
      >
        <gl-form-input
          id="schedule-name"
          :value="form.name"
          @blur="$emit('update-schedule-form', { type: 'name', value: $event.target.value })"
        />
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.description.title"
        label-size="sm"
        label-for="schedule-description"
      >
        <gl-form-input
          id="schedule-description"
          :value="form.description"
          @blur="$emit('update-schedule-form', { type: 'description', value: $event.target.value })"
        />
      </gl-form-group>
    </div>

    <gl-form-group
      :label="$options.i18n.fields.rules.title"
      label-size="sm"
      :invalid-feedback="$options.i18n.fields.rules.error"
      :state="validationState.rules"
    >
      <gl-card
        class="gl-border-gray-400 gl-bg-gray-10"
      >
      </gl-card>
    </gl-form-group>

  </gl-form>
</template>
