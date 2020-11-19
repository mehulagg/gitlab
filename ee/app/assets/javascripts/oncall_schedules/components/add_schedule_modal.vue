<script>
  import {GlModal, GlForm, GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem, GlSearchBoxByType} from '@gitlab/ui';
  import {s__, __} from '~/locale';

  const i18n = {
    selectTimezone: s__('OnCallSchedules|Select timezone'),
    search: __('Search'),
    noResults: __('No matching results'),
  };

  export default {
    i18n,
    inject: ['timezones'],
    data() {
      return {
        tzSearchTerm: '',
        ы
      }
    },
    components: {GlModal, GlForm, GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem, GlSearchBoxByType},
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

      },
      getFormattedTimezone(tz) {
        return `(UTC${tz.formatted_offset}) ${tz.abbr} ${tz.name}`;
      },
      isTimezoneSelected(tz) {

      },

    },
  };
</script>

<!--:text="selectedValue(gitlabField.fallback)"-->

<template>
  <gl-modal
    :modal-id="modalId"
    size="sm"
    :title="s__('OnCallSchedules|Add schedule')"
    :action-primary="$options.actionsProps.primary"
    :action-cancel="$options.actionsProps.cancel"
    @primary="createSchedule"
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
        <gl-dropdown
          id="schedule-timezone"
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
            @click="setSelectedTimezone(tz.identifier)"
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
