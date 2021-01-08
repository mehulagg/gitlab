<script>
import { GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import createFlash from '~/flash';
import IntegrationView from './integration_view.vue';

const INTEGRATION_VIEW_CONFIGS = {
  sourcegraph: {
    title: s__('ProfilePreferences|Sourcegraph'),
    label: s__('ProfilePreferences|Enable integrated code intelligence on code views'),
    formName: 'sourcegraph_enabled',
  },
  gitpod: {
    title: s__('ProfilePreferences|Gitpod'),
    label: s__('ProfilePreferences|Enable Gitpod integration'),
    formName: 'gitpod_enabled',
  },
};

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
    IntegrationView,
    GlButton,
  },
  inject: {
    integrationViews: {
      default: [],
    },
    themes: {
      default: [],
    },
    userFields: {
      default: {},
    },
    formEl: 'formEl',
    profilePreferencesPath: 'profilePreferencesPath',
    bodyClasses: 'bodyClasses',
  },
  integrationViewConfigs: INTEGRATION_VIEW_CONFIGS,
  data() {
    return {
      isSubmitEnabled: true,
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
  created() {
    this.formEl.addEventListener('ajax:beforeSend', this.handleLoading);
    this.formEl.addEventListener('ajax:success', this.handleSuccess);
    this.formEl.addEventListener('ajax:error', this.handleError);
  },
  beforeDestroy() {
    this.formEl.removeEventListener('ajax:beforeSend', this.handleLoading);
    this.formEl.removeEventListener('ajax:success', this.handleSuccess);
    this.formEl.removeEventListener('ajax:error', this.handleError);
  },
  methods: {
    handleLoading() {
      this.isSubmitEnabled = false;
    },
    handleSuccess(xhr) {
      const formData = new FormData(this.formEl);
      const { message, type } = xhr.detail?.[0];
      if (message) {
        createFlash({ message, type });
      }
      updateClasses(
        this.bodyClasses,
        this.applicationThemes[formData.get('user[theme_id]')].css_class,
        this.selectedLayout,
      );
      this.isSubmitEnabled = true;
    },
    handleError(error) {
      createFlash({ message: error });
      this.isSubmitEnabled = true;
    },
  },
};
</script>

<template>
  <div class="row gl-mt-3 js-preferences-form">
    <div v-if="integrationViews.length" class="col-sm-12">
      <hr data-testid="profile-preferences-integrations-rule" />
    </div>
    <div v-if="integrationViews.length" class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0" data-testid="profile-preferences-integrations-heading">
        {{ s__('ProfilePreferences|Integrations') }}
      </h4>
      <p>
        {{ s__('ProfilePreferences|Customize integrations with third party services.') }}
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
    <div class="col-lg-4 profile-settings-sidebar"></div>
    <div class="col-lg-8">
      <div class="form-group">
        <gl-button variant="success" name="commit" type="submit" :disabled="!isSubmitEnabled">
          {{ s__('ProfilePreferences|Save changes') }}
        </gl-button>
      </div>
    </div>
  </div>
</template>
