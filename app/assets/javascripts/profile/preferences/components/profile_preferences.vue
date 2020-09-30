<script>
import { GlButton } from '@gitlab/ui';
import GroupOverviewSelector from 'ee_else_ce/profile/preferences/components/group_overview_selector.vue';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import createFlash, { hideFlash, FLASH_TYPES } from '~/flash';

// TODO:
// - figure out if `app/views/profiles/preferences/_gitpod.html.haml` is being used
// - figure out if `app/views/profiles/preferences/_sourcegraph.html.haml` is being used

// Same, but new implementation:
// - image lazy load
// - checkbox default value
// - radio button direct submit (all fields)

// Differences to HAML implementation:
// - changed select2 to select
// - changed quote in "Show one file at a time on merge request’s Changes tab"
// - added `gl-button` class to submit
// - changed submit to call submit()

const CHECKBOX_FIELD_NAMES = [
  'user[render_whitespace_in_code]',
  'user[show_whitespace_in_diffs]',
  'user[view_diffs_file_by_file]',
  'user[time_format_in_24h]',
];

function updateClasses(bodyClasses = '', applicationTheme, layout) {
  // Remove body class for any previous theme, re-add current one
  document.body.classList.remove(...bodyClasses.split(' '));
  document.body.classList.add(applicationTheme);

  // Toggle container-fluid class
  if (layout === 'fluid') {
    document
      .querySelector('.content-wrapper .container-fluid')
      .classList.remove('container-limited');
  } else {
    document.querySelector('.content-wrapper .container-fluid').classList.add('container-limited');
  }
}

export default {
  name: 'ProfilePreferences',
  components: {
    GlButton,
    GroupOverviewSelector,
  },
  props: {
    themes: {
      type: Array,
      required: true,
    },
    schemes: {
      type: Array,
      required: true,
    },
    dashboardChoices: {
      type: Array,
      required: true,
    },
    firstDayOfWeekChoicesWithDefault: {
      type: Array,
      required: true,
    },
    layoutChoices: {
      type: Array,
      required: true,
    },
    languageChoices: {
      type: Array,
      required: true,
    },
    projectViewChoices: {
      type: Array,
      required: true,
    },
    groupViewChoices: {
      type: Array,
      default: () => [],
    },
    integrationViews: {
      type: Array,
      default: () => [],
    },
    userFields: {
      type: Object,
      required: true,
    },
    profilePreferencesPath: {
      type: String,
      required: true,
    },
    bodyClasses: {
      type: String,
      required: true,
    },
    featureFlags: {
      type: Object,
      required: true,
    },
  },
  data() {
    console.log(this.groupViewChoices);
    console.log(this.userFields);
    return {
      isSubmitEnabled: true,
      selectedTabWidth: this.userFields.tabWidth,
      selectedTheme: this.userFields.theme,
      selectedScheme: this.userFields.scheme,
      selectedLayout: this.userFields.layout,
      selectedDashboard: this.userFields.dashboard,
      selectedProjectView: this.userFields.projectView,
      selectedRenderWhitespaceInCode: this.userFields.renderWhitespaceInCode,
      selectedShowWhitespaceInDiffs: this.userFields.showWhitespaceInDiffs,
      selectedViewDiffsFileByFile: this.userFields.viewDiffsFileByFile,
      selectedPreferredLanguage: this.userFields.preferredLanguage,
      selectedFirstDayOfWeek: this.userFields.firstDayOfWeek,
      selectedTimeFormatIn24h: this.userFields.timeFormatIn24h,
      selectedTimeDisplayRelative: this.userFields.timeDisplayRelative,
    };
  },
  computed: {
    applicationThemes() {
      return this.themes.reduce((memo, theme) => {
        const { id, ...rest } = theme;
        return { ...memo, [id]: rest };
      }, {});
    },
  },
  methods: {
    async handleSubmit() {
      const formData = new FormData(this.$refs.form);
      // Ensure that checkboxes false values gets sent
      CHECKBOX_FIELD_NAMES.forEach(name => {
        if (formData.has(name)) {
          formData.set(name, 1);
        } else {
          formData.set(name, 0);
        }
      });
      for (const p of formData) {
        console.log(p);
      }
      // formData.set("user[tab_width]", "-1");
      this.isSubmitEnabled = false;
      try {
        const response = await axios.put('/profile/preferences', formData);
        const { message, status } = response.data;
        let type = FLASH_TYPES.NOTICE;
        if (status === 'error') {
          type = FLASH_TYPES.ALERT;
        }
        createFlash({ message, type });
        updateClasses(
          this.bodyClasses,
          this.applicationThemes[this.selectedTheme].css_class,
          this.selectedLayout,
        );
      } catch (error) {
        createFlash({ message: error });
      }

      this.isSubmitEnabled = true;
    },
  },
};
</script>

<template>
  <form ref="form" class="row gl-mt-3 js-preferences-form" accept-charset="UTF-8" @submit.prevent>
    <input name="utf8" type="hidden" value="✓" />
    <div class="col-lg-4 application-theme">
      <h4 class="gl-mt-0">
        {{ __('Navigation theme') }}
      </h4>
      <p>
        {{ __('Customize the appearance of the application header and navigation sidebar.') }}
      </p>
    </div>
    <div class="col-lg-8 application-theme">
      <div class="row">
        <label
          v-for="theme in themes"
          :key="theme.id"
          class="col-6 col-sm-4 col-md-3 gl-mb-5 gl-text-center"
          @click="handleSubmit"
        >
          <div :class="`preview ${theme.css_class}`"></div>
          <input v-model="selectedTheme" type="radio" :value="theme.id" name="user[theme_id]" />
          {{ theme.name }}
        </label>
      </div>
    </div>
    <div class="col-sm-12">
      <hr />
    </div>
    <div class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ __('Syntax highlighting theme') }}
      </h4>
      <p>
        {{ __('This setting allows you to customize the appearance of the syntax.') }}
        <a target="_blank" href="/help/user/profile/preferences#syntax-highlighting-theme">{{
          __('Learn more')
        }}</a
        >.
      </p>
    </div>
    <div class="col-lg-8 syntax-theme">
      <label
        v-for="scheme in schemes"
        :key="scheme.id"
        class="col-6 col-sm-4 col-md-3 gl-mb-5 gl-text-center"
        @click="handleSubmit"
      >
        <div class="preview">
          <img class="lazy" :data-src="scheme.image_url" />
        </div>
        <input
          v-model="selectedScheme"
          type="radio"
          :value="scheme.id"
          name="user[color_scheme_id]"
        />
        {{ scheme.name }}
      </label>
    </div>
    <div class="col-sm-12">
      <hr />
    </div>
    <div class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ __('Behavior') }}
      </h4>
      <p>
        {{
          __(
            'This setting allows you to customize the behavior of the system layout and default views.',
          )
        }}
        <a target="_blank" href="/help/user/profile/preferences#behavior">{{ __('Learn more') }}</a
        >.
      </p>
    </div>
    <div class="col-lg-8">
      <div class="form-group">
        <label class="label-bold" for="user_layout">
          {{ __('Layout width') }}
        </label>
        <div class="select-wrapper">
          <select
            id="user_layout"
            v-model="selectedLayout"
            class="form-control select-control"
            name="user[layout]"
            tabindex="-1"
            title="Layout width"
          >
            <option
              v-for="[optionName, optionValue] in layoutChoices"
              :key="optionValue"
              :value="optionValue"
            >
              {{ optionName }}
            </option>
          </select>
          <i aria-hidden="true" class="fa fa-chevron-down"> </i>
        </div>
        <div class="form-text text-muted">
          {{ __('Choose between fixed (max. 1280px) and fluid (100%) application layout.') }}
        </div>
      </div>
      <div class="form-group">
        <label class="label-bold" for="user_dashboard">
          {{ __('Homepage content') }}
        </label>
        <div class="select-wrapper">
          <select
            id="user_dashboard"
            v-model="selectedDashboard"
            class="form-control select-control"
            name="user[dashboard]"
            tabindex="-1"
            title="Homepage content"
          >
            <option
              v-for="[optionName, optionValue] in dashboardChoices"
              :key="optionValue"
              :value="optionValue"
            >
              {{ optionName }}
            </option>
          </select>
          <i aria-hidden="true" class="fa fa-chevron-down"> </i>
        </div>
        <div class="form-text text-muted">
          {{ __('Choose what content you want to see on your homepage.') }}
        </div>
      </div>

      <group-overview-selector :group-view-choices="groupViewChoices" :user-fields="userFields" />

      <div class="form-group">
        <label class="label-bold" for="user_project_view">
          {{ __('Project overview content') }}
        </label>
        <div class="select-wrapper">
          <select
            id="user_project_view"
            v-model="selectedProjectView"
            class="form-control select-control"
            name="user[project_view]"
            tabindex="-1"
            title="Project overview content"
          >
            <option
              v-for="[optionName, optionValue] in projectViewChoices"
              :key="optionValue"
              :value="optionValue"
            >
              {{ optionName }}
            </option>
          </select>
          <i aria-hidden="true" class="fa fa-chevron-down"> </i>
        </div>
        <div class="form-text text-muted">
          {{ __('Choose what content you want to see on a project’s overview page.') }}
        </div>
      </div>
      <div class="form-group form-check">
        <input
          id="user_render_whitespace_in_code"
          v-model="selectedRenderWhitespaceInCode"
          class="form-check-input"
          name="user[render_whitespace_in_code]"
          type="checkbox"
          :value="selectedRenderWhitespaceInCode"
        />
        <label class="form-check-label" for="user_render_whitespace_in_code">
          {{ __('Render whitespace characters in the Web IDE') }}
        </label>
      </div>
      <div class="form-group form-check">
        <input
          id="user_show_whitespace_in_diffs"
          v-model="selectedShowWhitespaceInDiffs"
          class="form-check-input"
          name="user[show_whitespace_in_diffs]"
          type="checkbox"
          :value="selectedShowWhitespaceInDiffs"
        />
        <label class="form-check-label" for="user_show_whitespace_in_diffs">
          {{ __('Show whitespace changes in diffs') }}
        </label>
      </div>
      <div v-if="featureFlags.viewDiffsFileByFile" class="form-group form-check">
        <input
          id="user_view_diffs_file_by_file"
          v-model="selectedViewDiffsFileByFile"
          class="form-check-input"
          name="user[view_diffs_file_by_file]"
          type="checkbox"
          :value="selectedViewDiffsFileByFile"
        />
        <label class="form-check-label" for="user_view_diffs_file_by_file">
          {{ __('Show one file at a time on merge request’s Changes tab') }}
        </label>
        <div class="form-text text-muted">
          {{
            __(
              'Instead of all the files changed, show only one file at a time. To switch between files, use the file browser.',
            )
          }}
        </div>
      </div>
      <div class="form-group">
        <label class="label-bold" for="user_tab_width">
          {{ __('Tab width') }}
        </label>
        <input
          id="user_tab_width"
          v-model="selectedTabWidth"
          class="form-control"
          name="user[tab_width]"
          min="1"
          max="12"
          required="required"
          type="number"
        />
        <div class="form-text text-muted">
          {{ __('Must be a number between 1 and 12') }}
        </div>
      </div>
    </div>
    <div class="col-sm-12">
      <hr />
    </div>
    <div class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ __('Localization') }}
      </h4>
      <p>
        {{ __('Customize language and region related settings.') }}
        <a target="_blank" href="/help/user/profile/preferences#localization">
          {{ __('Learn more') }} </a
        >.
      </p>
    </div>
    <div class="col-lg-8">
      <div class="form-group">
        <label class="label-bold" for="user_preferred_language">
          {{ __('Language') }}
        </label>
        <div class="select-wrapper">
          <select
            id="user_preferred_language"
            v-model="selectedPreferredLanguage"
            class="form-control select-control"
            name="user[preferred_language]"
            tabindex="-1"
            title="Language"
          >
            <option
              v-for="[optionName, optionValue] in languageChoices"
              :key="optionValue"
              :value="optionValue"
            >
              {{ optionName }}
            </option>
          </select>
          <i aria-hidden="true" class="fa fa-chevron-down"> </i>
        </div>
        <div class="form-text text-muted">
          {{ __('This feature is experimental and translations are not complete yet') }}
        </div>
      </div>
      <div class="form-group">
        <label class="label-bold" for="user_first_day_of_week">
          {{ __('First day of the week') }}
        </label>
        <div class="select-wrapper">
          <select
            id="user_first_day_of_week"
            v-model="selectedFirstDayOfWeek"
            class="form-control select-control"
            name="user[first_day_of_week]"
            tabindex="-1"
            title="First day of the week"
          >
            <option
              v-for="[optionName, optionValue] in firstDayOfWeekChoicesWithDefault"
              :key="optionValue"
              :value="optionValue"
            >
              {{ optionName }}
            </option>
          </select>
          <i aria-hidden="true" class="fa fa-chevron-down"> </i>
        </div>
      </div>
    </div>

    <!-- <div v-if="featureFlags.userTimeSettings"> -->
    <div class="col-sm-12">
      <hr />
    </div>
    <div class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ __('Time preferences') }}
      </h4>
      <p>
        {{ __('These settings will update how dates and times are displayed for you.') }}
      </p>
    </div>
    <div class="col-lg-8">
      <div class="form-group">
        <h5>
          {{ __('Time format') }}
        </h5>
        <div class="checkbox-icon-inline-wrapper">
          <input
            id="user_time_format_in_24h"
            v-model="selectedTimeFormatIn24h"
            type="checkbox"
            name="user[time_format_in_24h]"
            :value="selectedTimeFormatIn24h"
          />
          <label for="user_time_format_in_24h">
            {{ __('Display time in 24-hour format') }}
          </label>
        </div>
        <div class="checkbox-icon-inline-wrapper">
          <input
            id="user_time_display_relative"
            v-model="selectedTimeDisplayRelRelative"
            type="checkbox"
            name="user[time_display_relative]"
            :value="selectedTimeDisplayRelRelative"
          />
          <label for="user_time_display_relative">
            {{ __('For example: 30 mins ago.') }}
          </label>
        </div>
      </div>
    </div>
    <div class="col-sm-12">
      <hr />
    </div>
    <div id="integrations" class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ __('Integrations') }}
      </h4>
      <p>
        {{ __('Customize integrations with third party services.') }}
      </p>
    </div>
    <div class="col-lg-8">
      <div v-for="integrationViews" ></div>
    </div>

    <div class="col-lg-4 profile-settings-sidebar"></div>
    <div class="col-lg-8">
      <div class="form-group">
        <gl-button
          variant="success"
          name="commit"
          :disabled="!isSubmitEnabled"
          @click="handleSubmit"
          @keyup.enter="handleSubmit"
        >
          {{ __('Save changes') }}
        </gl-button>
      </div>
    </div>
  </form>
</template>
