<script>
  import {isEqual, isEmpty} from 'lodash';
  import {GlModal, GlForm, GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem, GlSearchBoxByType} from '@gitlab/ui';
  import {s__, __} from '~/locale';

  const i18n = {
    selectTimezone: s__('OnCallSchedules|Select timezone'),
    search: __('Search'),
    noResults: __('No matching results'),
    cancel: __('Cancel'),
    addSchedule: s__('OnCallSchedules|Add schedule'),
    fields: {
      name: {title: __('Name')},
      description: {title: __('Description')},
      timezone: {
        title: __('Timezone'),
        description: s__('OnCallSchedules|Sets the default timezone for the schedule, for all participants'),
      }
    },
  };

  export default {
    i18n,
    inject: ['timezones'],
    data() {
      return {
        tzSearchTerm: '',
        form: {
          name: '',
          description: '',
          timezone: {},
        },
      }
    },
    components: {GlModal, GlForm, GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem, GlSearchBoxByType},
    actionsProps: {
      primary: {
        text: i18n.addSchedule,
        attributes: [
          {variant: 'info'},
        ]
      },
      cancel: {
        text: i18n.cancel,
      }
    },
    props: {
      modalId: {
        type: String,
        required: true,
      },
    },
    computed: {
      filteredTimezones() {
        const lowerCaseTzSearchTerm = this.tzSearchTerm.toLowerCase();
        return this.timezones.filter(tz => {
          return this.getFormattedTimezone(tz).toLowerCase().includes(lowerCaseTzSearchTerm);
        });
      },
      noResults() {
        return !this.filteredTimezones.length;
      },
      selectedTimezone() {
        return isEmpty(this.form.timezone) ? i18n.selectTimezone : this.getFormattedTimezone(this.form.timezone);
      },
    },
    methods: {
      createSchedule() {

      },
      onReset() {
      },
      onSubmit() {
      },
      hide() {
        this.alert = null;
      },
      formChange(form) {
        this.form = form;
      },
      setSelectedTimezone(tz) {
        this.form.timezone = tz;
      },
      getFormattedTimezone(tz) {
        return `(UTC${tz.formatted_offset}) ${tz.abbr} ${tz.name}`;
      },
      isTimezoneSelected(tz) {
        return isEqual(tz, this.form.timezone);
      },
    },
  };
</script>

<!--:text="selectedValue(gitlabField.fallback)"-->

<template>
  <gl-modal
    :modal-id="modalId"
    size="sm"
    :title="$options.i18n.addSchedule"
    :action-primary="$options.actionsProps.primary"
    :action-cancel="$options.actionsProps.cancel"
    @primary="createSchedule"
  >
    <gl-form @submit="onSubmit" @reset="onReset">
      <gl-form-group
        :label="$options.i18n.fields.name.title"
        label-size="sm"
        label-for="schedule-name"
      >
        <gl-form-input id="schedule-name" v-model="form.name"/>
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.description.title"
        label-size="sm"
        label-for="schedule-description"
      >
        <gl-form-input id="schedule-description" v-model="form.description"/>
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.timezone.title"
        label-size="sm"
        :description="$options.i18n.fields.timezone.description"
        label-for="schedule-timezone"
      >
        <gl-dropdown
          id="schedule-timezone"
          :text="selectedTimezone"
          class="timezone-dropdown gl-w-full"
          :header-text="$options.i18n.selectTimezone"
        >
          <gl-search-box-by-type
            v-model="tzSearchTerm"
          />
          <gl-dropdown-item
            v-for="tz in filteredTimezones"
            :key="getFormattedTimezone(tz)"
            :is-checked="isTimezoneSelected(tz)"
            is-check-item
            @click="setSelectedTimezone(tz)"
          >
            <span class="gl-white-space-nowrap"> {{ getFormattedTimezone(tz) }}</span>
          </gl-dropdown-item>
          <gl-dropdown-item
            v-if="noResults"
          >
            {{ $options.i18n.noResults }}
          </gl-dropdown-item>
        </gl-dropdown>
      </gl-form-group>
    </gl-form>
  </gl-modal>
</template>
