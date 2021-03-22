<script>
import { GlButton, GlLoadingIcon, GlAlert } from '@gitlab/ui';
import Api from '~/api';
import { mergeUrlParams } from '~/lib/utils/url_utility';
import { s__, sprintf } from '~/locale';
import { SUGGESTED_CI_TEMPLATES, API_CI_TEMPLATE_TYPE } from '../../constants';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
    GlAlert,
  },
  i18n: {
    title: s__('Pipelines|Try a sample CI/CD file'),
    subtitle: s__(
      'Pipelines|Use a sample file to implement GitLab CI/CD based on your project’s language/framework.',
    ),
    cta: s__('Pipelines|Use template'),
    description: s__(
      'Pipelines|Continuous deployment template to test and deploy your %{name} project.',
    ),
    errorMessage: s__('Pipelines|An error occurred. Please try again.'),
  },
  inject: ['projectId', 'addCiYmlPath'],
  data() {
    return {
      isLoading: false,
      hasError: false,
      templates: [],
    };
  },
  mounted() {
    this.fetchTemplates();
  },
  methods: {
    fetchTemplates() {
      this.isLoading = true;

      Api.projectTemplates(this.projectId, API_CI_TEMPLATE_TYPE, { per_page: 100 })
        .then(({ data }) => this.setCiTemplates(data))
        .catch(() => {
          this.hasError = true;
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
    setCiTemplates(allTemplates) {
      this.templates = allTemplates
        .filter((template) => SUGGESTED_CI_TEMPLATES[template.key])
        .map(({ name, key }) => {
          return {
            name,
            logoPath: SUGGESTED_CI_TEMPLATES[key].logoPath,
            link: mergeUrlParams({ template: key }, this.addCiYmlPath),
            description: sprintf(this.$options.i18n.description, { name }),
          };
        });
    },
  },
};
</script>
<template>
  <div>
    <h2>{{ $options.i18n.title }}</h2>
    <p>{{ $options.i18n.subtitle }}</p>

    <div v-if="isLoading">
      <gl-loading-icon data-testid="loading-icon" />
    </div>

    <gl-alert v-if="hasError" variant="danger" :dismissible="false" class="gl-mt-3">
      {{ $options.i18n.errorMessage }}
    </gl-alert>
    <ul v-else class="gl-list-style-none gl-pl-0">
      <li v-for="template in templates" :key="template.key">
        <div
          class="gl-display-flex gl-align-items-center gl-justify-content-space-between gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-pb-5 gl-pt-5"
        >
          <div class="gl-display-flex gl-flex-direction-row gl-align-items-center">
            <img
              width="64"
              height="64"
              :src="template.logoPath"
              class="gl-mr-6"
              data-testid="template-logo"
            />
            <div class="gl-flex-direction-row">
              <strong class="gl-text-gray-800" data-testid="template-name">{{
                template.name
              }}</strong>
              <p class="gl-mb-0" data-testid="template-description">{{ template.description }}</p>
            </div>
          </div>
          <gl-button
            category="primary"
            variant="confirm"
            :href="template.link"
            data-testid="template-link"
            >{{ $options.i18n.cta }}</gl-button
          >
        </div>
      </li>
    </ul>
  </div>
</template>
