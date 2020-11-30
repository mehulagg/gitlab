<script>
import GroupOverviewSelector from 'ee_else_ce/profile/preferences/components/group_overview_selector.vue';

import IntegrationView from './integration_view.vue';
import { INTEGRATION_VIEW_CONFIGS, i18n } from '../constants';

export default {
  name: 'ProfilePreferences',
  components: {
    GroupOverviewSelector,
    IntegrationView,
  },
  inject: {
    firstDayOfWeekChoicesWithDefault: 'firstDayOfWeekChoicesWithDefault',
    dashboardChoices: 'dashboardChoices',
    layoutChoices: 'layoutChoices',
    languageChoices: 'languageChoices',
    projectViewChoices: 'projectViewChoices',
    integrationViews: {
      default: [],
    },
    userFields: 'userFields',
    featureFlags: 'featureFlags',
  },
  data() {
    return {
      selectedTabWidth: this.userFields.tab_width,
      selectedLayout: this.userFields.layout,
      selectedDashboard: this.userFields.dashboard,
      selectedProjectView: this.userFields.project_view,
      selectedRenderWhitespaceInCode: this.userFields.render_whitespace_in_code,
      selectedShowWhitespaceInDiffs: this.userFields.show_whitespace_in_diffs,
      selectedViewDiffsFileByFile: this.userFields.view_diffs_file_by_file,
      selectedPreferredLanguage: this.userFields.preferred_language,
      selectedFirstDayOfWeek: this.userFields.first_day_of_week,
      selectedTimeFormatIn24h: this.userFields.time_format_in24h,
      selectedTimeDisplayRelative: this.userFields.time_display_relative,
    };
  },
  i18n,
  integrationViewConfigs: INTEGRATION_VIEW_CONFIGS,
};
</script>

<template>
  <div class="row gl-mt-3 js-preferences-form">
    <div class="col-sm-12">
      <hr />
    </div>
    <div class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ $options.i18n.behavior }}
      </h4>
      <p>
        {{ $options.i18n.behaviorDescription }}
        <a target="_blank" href="/help/user/profile/preferences#behavior">
          {{ $options.i18n.learnMore }} </a
        >.
      </p>
    </div>
    <div class="col-lg-8">
      <div class="form-group">
        <label class="label-bold" for="user_layout">
          {{ $options.i18n.layoutWidth }}
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
          {{ $options.i18n.layoutWidthDescription }}
        </div>
      </div>
      <div class="form-group">
        <label class="label-bold" for="user_dashboard">
          {{ $options.i18n.homepageContent }}
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
          {{ $options.i18n.homepageContentDescription }}
        </div>
      </div>

      <group-overview-selector />

      <div class="form-group">
        <label class="label-bold" for="user_project_view">
          {{ $options.i18n.projectOverview }}
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
          {{ $options.i18n.projectOverviewDescription }}
        </div>
      </div>
      <div class="form-group form-check">
        <input name="user[render_whitespace_in_code]" type="hidden" value="0" />
        <input
          id="user_render_whitespace_in_code"
          v-model="selectedRenderWhitespaceInCode"
          class="form-check-input"
          name="user[render_whitespace_in_code]"
          type="checkbox"
          value="1"
        />
        <label class="form-check-label" for="user_render_whitespace_in_code">
          {{ $options.i18n.renderWhitespaceLabel }}
        </label>
      </div>
      <div class="form-group form-check">
        <input name="user[show_whitespace_in_diffs]" type="hidden" value="0" />
        <input
          id="user_show_whitespace_in_diffs"
          v-model="selectedShowWhitespaceInDiffs"
          class="form-check-input"
          name="user[show_whitespace_in_diffs]"
          type="checkbox"
          value="1"
        />
        <label class="form-check-label" for="user_show_whitespace_in_diffs">
          {{ $options.i18n.showWhitespaceLabel }}
        </label>
      </div>
      <div
        v-if="featureFlags.viewDiffsFileByFile"
        class="form-group form-check"
        data-testid="view-diffs-file-by-file"
      >
        <input name="user[view_diffs_file_by_file]" type="hidden" value="0" />
        <input
          id="user_view_diffs_file_by_file"
          v-model="selectedViewDiffsFileByFile"
          class="form-check-input"
          name="user[view_diffs_file_by_file]"
          type="checkbox"
          value="1"
        />
        <label class="form-check-label" for="user_view_diffs_file_by_file">
          {{ $options.i18n.showOneFileLabel }}
        </label>
        <div class="form-text text-muted">
          {{ $options.i18n.showOneFileDescription }}
        </div>
      </div>
      <div class="form-group">
        <label class="label-bold" for="user_tab_width">
          {{ $options.i18n.tabWidth }}
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
          {{ $options.i18n.tabWidthDescription }}
        </div>
      </div>
    </div>
    <div class="col-sm-12">
      <hr />
    </div>
    <div class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ $options.i18n.localization }}
      </h4>
      <p>
        {{ $options.i18n.localizationDescription }}
        <a target="_blank" href="/help/user/profile/preferences#localization">
          {{ $options.i18n.learnMore }} </a
        >.
      </p>
    </div>
    <div class="col-lg-8">
      <div class="form-group">
        <label class="label-bold" for="user_preferred_language">
          {{ $options.i18n.language }}
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
          {{ $options.i18n.experimentalDescription }}
        </div>
      </div>
      <div class="form-group">
        <label class="label-bold" for="user_first_day_of_week">
          {{ $options.i18n.firstDayOfTheWeek }}
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

    <div
      v-if="featureFlags.userTimeSettings"
      class="col-sm-12"
      data-testid="user-time-settings-rule"
    >
      <hr />
    </div>
    <div
      v-if="featureFlags.userTimeSettings"
      class="col-lg-4 profile-settings-sidebar"
      data-testid="user-time-settings-heading"
    >
      <h4 class="gl-mt-0">
        {{ $options.i18n.timePreferences }}
      </h4>
      <p>
        {{ $options.i18n.timePreferencesDescription }}
      </p>
    </div>
    <div
      v-if="featureFlags.userTimeSettings"
      class="col-lg-8"
      data-testid="user-time-settings-option"
    >
      <h5>
        {{ $options.i18n.timeFormat }}
      </h5>
      <div class="form-group form-check">
        <input name="user[render_whitespace_in_code]" type="hidden" value="0" />
        <input
          id="user_render_whitespace_in_code"
          v-model="selectedRenderWhitespaceInCode"
          class="form-check-input"
          name="user[render_whitespace_in_code]"
          type="checkbox"
          value="1"
        />
        <label class="form-check-label" for="user_time_format_in_24h">
          {{ $options.i18n.timeFormatLabel }}
        </label>
      </div>
      <div class="form-group form-check">
        <input name="user[time_display_relative]" type="hidden" value="0" />
        <input
          id="user_time_display_relative"
          v-model="selectedTimeDisplayRelative"
          class="form-check-input"
          name="user[time_display_relative]"
          type="checkbox"
          value="1"
        />
        <label class="form-check-label" for="user_time_display_relative">
          {{ $options.i18n.relativeTimeLabel }}
        </label>
      </div>
    </div>

    <div v-if="integrationViews.length" class="col-sm-12">
      <hr data-testid="profile-preferences-integrations-rule" />
    </div>
    <div v-if="integrationViews.length" class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0" data-testid="profile-preferences-integrations-heading">
        {{ $options.i18n.integrations }}
      </h4>
      <p>
        {{ $options.i18n.integrationsDescription }}
      </p>
    </div>
    <div v-if="integrationViews.length" class="col-lg-8">
      <integration-view
        v-for="view in integrationViews"
        :key="view.name"
        :help-link="view.help_link"
        :message="view.message"
        :message-url="view.message_url"
        :config="$options.integrationViewConfigs[view.name]"
      />
    </div>
  </div>
</template>
