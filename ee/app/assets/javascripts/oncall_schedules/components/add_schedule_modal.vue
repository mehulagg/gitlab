<script>
import { isEqual, isEmpty } from 'lodash';
import {
  GlModal,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlAlert,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import CreateOncallScheduleMutation from '../graphql/create_oncall_schedule.mutation.graphql';

export const i18n = {
  selectTimezone: s__('OnCallSchedules|Select timezone'),
  search: __('Search'),
  noResults: __('No matching results'),
  cancel: __('Cancel'),
  addSchedule: s__('OnCallSchedules|Add schedule'),
  fields: {
    name: { title: __('Name') },
    description: { title: __('Description') },
    timezone: {
      title: __('Timezone'),
      description: s__(
        'OnCallSchedules|Sets the default timezone for the schedule, for all participants',
      ),
    },
  },
  errorMsg: s__('OnCallSchedules|Failed to add schedule'),
};

export default {
  i18n,
  inject: ['projectPath', 'timezones'],
  components: {
    GlModal,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    GlAlert,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      loading: false,
      tzSearchTerm: '',
      form: {
        name: '',
        description: '',
        timezone: {},
      },
      showErrorAlert: false,
      error: '',
    };
  },
  computed: {
    actionsProps() {
      return {
        primary: {
          text: i18n.addSchedule,
          attributes: [{ variant: 'info' }, { loading: this.loading }],
        },
        cancel: {
          text: i18n.cancel,
        },
      };
    },
    filteredTimezones() {
      const lowerCaseTzSearchTerm = this.tzSearchTerm.toLowerCase();
      return this.timezones.filter(tz => {
        return this.getFormattedTimezone(tz)
          .toLowerCase()
          .includes(lowerCaseTzSearchTerm);
      });
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
    createSchedule(bvModalEvt) {
      bvModalEvt.preventDefault();

      this.loading = true;

      this.$apollo
        .mutate({
          mutation: CreateOncallScheduleMutation,
          variables: {
            oncallScheduleCreateInput: {
              projectPath: this.projectPath,
              ...this.form,
              timezone: this.form.timezone.identifier,
            },
          },
        })
        .then(({ data: { oncallScheduleCreate: { errors: [error] } } }) => {
          if (error) {
            throw error;
          }
          this.$refs.createScheduleModal.hide();
        })
        .catch(error => {
          this.error = error;
          this.showErrorAlert = true;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    setSelectedTimezone(tz) {
      this.form.timezone = tz;
    },
    getFormattedTimezone(tz) {
      return __(`(UTC${tz.formatted_offset}) ${tz.abbr} ${tz.name}`);
    },
    isTimezoneSelected(tz) {
      return isEqual(tz, this.form.timezone);
    },
  },
};
</script>

<template>
  <gl-modal
    id="modalId"
    ref="createScheduleModal"
    :modal-id="modalId"
    size="sm"
    :title="$options.i18n.addSchedule"
    :action-primary="actionsProps.primary"
    :action-cancel="actionsProps.cancel"
    @primary="createSchedule"
  >
    <gl-alert v-if="showErrorAlert" variant="danger" @dismiss="showErrorAlert = false">
      {{ error || $options.i18n.errorMsg }}
    </gl-alert>
    <gl-form @submit="createSchedule">
      <gl-form-group
        :label="$options.i18n.fields.name.title"
        label-size="sm"
        label-for="schedule-name"
      >
        <gl-form-input id="schedule-name" v-model="form.name" />
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.fields.description.title"
        label-size="sm"
        label-for="schedule-description"
      >
        <gl-form-input id="schedule-description" v-model="form.description" />
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
          <gl-search-box-by-type v-model="tzSearchTerm" />
          <gl-dropdown-item
            v-for="tz in filteredTimezones"
            :key="getFormattedTimezone(tz)"
            :is-checked="isTimezoneSelected(tz)"
            is-check-item
            @click="setSelectedTimezone(tz)"
          >
            <span class="gl-white-space-nowrap"> {{ getFormattedTimezone(tz) }}</span>
          </gl-dropdown-item>
          <gl-dropdown-item v-if="noResults">
            {{ $options.i18n.noResults }}
          </gl-dropdown-item>
        </gl-dropdown>
      </gl-form-group>
    </gl-form>
  </gl-modal>
</template>
