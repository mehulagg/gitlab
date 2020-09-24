<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';

// TODO:
// - figure out validation of form submission + flash display
// - finalize haml migration of `group_overview_selector` and `integration_views`
// - figure out if `app/views/profiles/preferences/_gitpod.html.haml` is being used
// - figure out if `app/views/profiles/preferences/_sourcegraph.html.haml` is being used

// Differences to HAML implementation:
// - Removed lazy loading of images
// - changed select2 to select
// - changed quote in "Show one file at a time on merge request’s Changes tab"
// - added `gl-button` class to submit
// - changed submit to call submit()

function updateClasses(bodyClasses, applicationTheme, layout) {
  // Remove body class for any previous theme, re-add current one
  document.body.classList.remove(bodyClasses.split(' '));
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

function updateFlash(flash) {
  // Show flash messages
  if (flash.notice) {
    createFlash({ message: flash.discard(flash.notice), type: 'notice' });
  } else if (flash.alert) {
    createFlash({ message: flash.discard(flash.alert), type: 'alert' });
  }
}

export default {
  name: 'ProfilePreferences',
  components: {
    GlButton,
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
    return {
      isSubmitEnabled: true,
    };
  },
  methods: {
    async handleSubmit() {
      const formData = new FormData(this.$refs.form);
      this.isSubmitEnabled = false;
      const response = await axios.post('/profile/preferences', formData);
      console.log(response);

      updateClasses(
        this.bodyClasses.split,
        this.userFields.applicationTheme,
        this.userFields.layout,
      );
      // updateFlash(this.flash);

      window.location.reload();
    },
  },
};

// action="/profile/preferences"
// data-remote="true"
// method="post"
</script>

<template>
  <form ref="form" class="row gl-mt-3 js-preferences-form" accept-charset="UTF-8" @submit.prevent>
    <input name="utf8" type="hidden" value="✓" /><input type="hidden" name="_method" value="put" />
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
        >
          <div :class="`preview ${theme.css_class}`"></div>
          <input
            type="radio"
            :value="theme.id"
            :checked="userFields.theme === theme.id"
            name="user[theme_id]"
          />
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
      >
        <div class="preview">
          <img :src="scheme.image_url" />
        </div>
        <input
          type="radio"
          :value="scheme.id"
          :checked="userFields.scheme === scheme.id"
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
            class="form-control select-control"
            name="user[layout]"
            tabindex="-1"
            title="Layout width"
          >
            <option
              v-for="[optionName, optionValue] in layoutChoices"
              :key="optionValue"
              :value="optionValue"
              :selected="optionValue === userFields.layout"
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
            class="form-control select-control"
            name="user[dashboard]"
            tabindex="-1"
            title="Homepage content"
          >
            <option
              v-for="[optionName, optionValue] in dashboardChoices"
              :key="optionValue"
              :value="optionValue"
              :selected="optionValue === userFields.dashboard"
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
      <!--
      = render_if_exists 'profiles/preferences/group_overview_selector', f: f # EE-specific
      <div class="form-group">
        <label class="label-bold" for="user_group_view">
          {{ __('Group overview conte nt
        </label>
        <select
          class="form-control select-control"
          name="user[group_view]"
          tabindex="-1"
          title="Group overview content"
        >
          <option
              v-for="[optionName, optionValue] in groupViewChoices"
              :key="optionValue"
              :value="optionValue"
              :selected="optionValue === userFields.group"
            >
              {{ optionName }}
            </option>
          <option selected="selected" value="details">Details (default)</option>
          <option value="security_dashboard">Security dashboard</option>
        </select>
        <div class="form-text text-muted">
          {{ __('Choose what content you want to see on a group’s overview pag e.
        </div>
      </div> -->

      <div class="form-group">
        <label class="label-bold" for="user_project_view">
          {{ __('Project overview content') }}
        </label>
        <div class="select-wrapper">
          <select
            class="form-control select-control"
            name="user[project_view]"
            tabindex="-1"
            title="Project overview content"
          >
            <option
              v-for="[optionName, optionValue] in projectViewChoices"
              :key="optionValue"
              :value="optionValue"
              :selected="optionValue === userFields.projectView"
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
        <input name="user[render_whitespace_in_code]" type="hidden" value="0" />
        <input
          class="form-check-input"
          type="checkbox"
          value="1"
          :checked="userFields.renderWhitespaceInCode"
          name="user[render_whitespace_in_code]"
        />
        <label class="form-check-label" for="user_render_whitespace_in_code">
          {{ __('Render whitespace characters in the Web IDE') }}
        </label>
      </div>
      <div class="form-group form-check">
        <input name="user[show_whitespace_in_diffs]" type="hidden" value="0" />
        <input
          class="form-check-input"
          type="checkbox"
          value="1"
          :checked="userFields.showWhitespaceInDiffs"
          name="user[show_whitespace_in_diffs]"
        />
        <label class="form-check-label" for="user_show_whitespace_in_diffs">
          {{ __('Show whitespace changes in diffs') }}
        </label>
      </div>
      <div v-if="featureFlags.viewDiffsFileByFile" class="form-group form-check">
        <input name="user[view_diffs_file_by_file]" type="hidden" value="0" />
        <input
          class="form-check-input"
          type="checkbox"
          :checked="userFields.viewDiffsFileByFile"
          value="1"
          name="user[view_diffs_file_by_file]"
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
          class="form-control"
          min="1"
          max="12"
          required="required"
          type="number"
          :value="userFields.tabWidth"
          name="user[tab_width]"
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
            class="form-control select-control"
            name="user[preferred_language]"
            tabindex="-1"
            title="Language"
          >
            <option
              v-for="[optionName, optionValue] in languageChoices"
              :key="optionValue"
              :value="optionValue"
              :selected="optionValue === userFields.preferredLanguage"
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
        <select
          class="form-control select-control"
          name="user[first_day_of_week]"
          tabindex="-1"
          title="First day of the week"
        >
          <option
            v-for="[optionName, optionValue] in firstDayOfWeekChoicesWithDefault"
            :key="optionValue"
            :value="optionValue"
            :selected="optionValue === userFields.firstDayOfWeek"
          >
            {{ optionName }}
          </option>
        </select>
      </div>
    </div>

    <!-- = render 'integrations', f: f
     - if Feature.enabled?(:user_time_settings)
      .col-sm-12
        %hr
      .col-lg-4.profile-settings-sidebar
        %h4.gl-mt-0= s_('Preferences|Time preferences')
        %p= s_('Preferences|These settings will update how dates and times are displayed for you.')
      .col-lg-8
        .form-group
          %h5= s_('Preferences|Time format')
          .checkbox-icon-inline-wrapper
            - time_format_label = capture do
              = s_('Preferences|Display time in 24-hour format')
            = f.check_box :time_format_in_24h
            = f.label :time_format_in_24h do
              = time_format_label
          %h5= s_('Preferences|Time display')
          .checkbox-icon-inline-wrapper
            - time_display_label = capture do
              = s_('Preferences|Use relative times')
            = f.check_box :time_display_relative
            = f.label :time_display_relative do
              = time_display_label
            .form-text.text-muted
              = s_('Preferences|For example: 30 mins ago.')

      .col-sm-12
        %hr

      .col-lg-4.profile-settings-sidebar#integrations
        %h4.gl-mt-0
          = s_('Preferences|Integrations')
        %p
          = s_('Preferences|Customize integrations with third party services.')
          = succeed '.' do
            = link_to _('Learn more'), help_page_path('user/profile/preferences.md', anchor: 'integrations'), target: '_blank'

      .col-lg-8
        - integration_views.each do |view|
          = render view, f: f -->

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
