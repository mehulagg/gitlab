<script>
import { isEqual, isEmpty } from 'lodash';
import {
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import { getFormattedTimezone } from '../utils/common_utils';

export const i18n = {
  selectTimezone: s__('OnCallSchedules|Select timezone'),
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
    timezone: {
      title: __('Timezone'),
      description: s__(
        'OnCallSchedules|Sets the default timezone for the schedule, for all participants',
      ),
      validation: {
        empty: __("Can't be empty"),
      },
    },
  },
  errorMsg: s__('OnCallSchedules|Failed to add schedule'),
};

export default {
  i18n,
  inject: ['projectPath', 'timezones'],
  components: {
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
  },
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
    };
  },
  computed: {
    filteredTimezones() {
      const lowerCaseTzSearchTerm = this.tzSearchTerm.toLowerCase();
      return this.timezones.filter((tz) =>
        this.getFormattedTimezone(tz).toLowerCase().includes(lowerCaseTzSearchTerm),
      );
    },
    noResults() {
      return !this.filteredTimezones.length;
    },
    selectedTimezone() {
      return isEmpty(this.form.timezone)
        ? i18n.selectTimezone
        : this.getFormattedTimezone(this.form.timezone);
    },
  },
  methods: {
    getFormattedTimezone(tz) {
      return getFormattedTimezone(tz);
    },
    isTimezoneSelected(tz) {
      return isEqual(tz, this.form.timezone);
    },
    updateFormValues(type, value) {
      this.$emit('update-schedule-form', { type, value });
      this.$emit('validate-form', type);
    },
  },
};
</script>

<template>
  <gl-form>
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
        @blur="updateFormValues('name', $event.target.value)"
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
        @blur="updateFormValues('description', $event.target.value)"
      />
    </gl-form-group>

    <gl-form-group
      :label="$options.i18n.fields.timezone.title"
      label-size="sm"
      label-for="schedule-timezone"
      :description="$options.i18n.fields.timezone.description"
      :state="validationState.timezone"
      :invalid-feedback="$options.i18n.fields.timezone.validation.empty"
      requried
    >
      <gl-dropdown
        id="schedule-timezone"
        :text="selectedTimezone"
        class="timezone-dropdown gl-w-full"
        :header-text="$options.i18n.selectTimezone"
        :class="{ 'invalid-dropdown': !validationState.timezone }"
        @hide="$emit('validate-form', 'timezone')"
      >
        <gl-search-box-by-type v-model.trim="tzSearchTerm" />
        <gl-dropdown-item
          v-for="tz in filteredTimezones"
          :key="getFormattedTimezone(tz)"
          :is-checked="isTimezoneSelected(tz)"
          is-check-item
          @click="$emit('update-schedule-form', { type: 'timezone', value: tz })"
        >
          <span class="gl-white-space-nowrap"> {{ getFormattedTimezone(tz) }}</span>
        </gl-dropdown-item>
        <gl-dropdown-item v-if="noResults">
          {{ $options.i18n.noResults }}
        </gl-dropdown-item>
      </gl-dropdown>
    </gl-form-group>
  </gl-form>
</template>
