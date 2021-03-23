<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import Api from '~/api';
import { __, sprintf } from '~/locale';

const TEMPLATE_TYPE = 'gitlab_ci_ymls';
const TEMPLATES = {
  Android: { logo: 'android' },
  Bash: { logo: 'bash' },
  'C++': { logo: 'c_plus_plus' },
  Clojure: { logo: 'clojure' },
  Composer: { logo: 'composer' },
  Crystal: { logo: 'crystal' },
  Dart: { logo: 'dart' },
  Django: { logo: 'django' },
  Docker: { logo: 'docker' },
  Elixir: { logo: 'elixir' },
  'iOS-Fastlane': { logo: 'fastlane' },
  Flutter: { logo: 'flutter' },
  Go: { logo: 'go_logo' },
  Gradle: { logo: 'gradle' },
  Grails: { logo: 'grails' },
  Dotnet: { logo: 'dotnet' },
  Rails: { logo: 'rails' },
  Julia: { logo: 'julia' },
  Laravel: { logo: 'laravel' },
  Latex: { logo: 'latex' },
  Maven: { logo: 'maven' },
  Mono: { logo: 'mono' },
  NodeJS: { logo: 'node' },
  NPM: { logo: 'npm' },
  OpenShift: { logo: 'openshift' },
  Packer: { logo: 'packer' },
  PHP: { logo: 'php' },
  python: { logo: 'python' },
  Ruby: { logo: 'ruby' },
  Rust: { logo: 'rust' },
  Scala: { logo: 'scala' },
  Swift: { logo: 'swift' },
  Terraform: { logo: 'terraform' },
};

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  i18n: {
    title: __('Try a sample CI/CD file'),
    subtitle: __(
      'Use a sample file to implement GitLab CI/CD based on your project’s language/framework.',
    ),
    cta: __('Use template'),
    description: __('Continuous deployment template to test and deploy your %{name} project.'),
  },
  props: {
    projectId: {
      type: String,
      required: true,
    },
    addCiYmlPath: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      isLoading: false,
      templates: [],
    };
  },
  mounted() {
    this.fetchTemplates();
  },
  methods: {
    fetchTemplates() {
      this.isLoading = true;

      Api.projectTemplates(this.projectId, TEMPLATE_TYPE, { per_page: 100 })
        .then(({ data }) => {
          this.templates = data.reduce((templates, template) => {
            if (TEMPLATES[template.key]) {
              return templates.concat({
                ...template,
                ...TEMPLATES[template.key],
                logoPath: `/assets/illustrations/logos/${TEMPLATES[template.key].logo}.svg`,
                link: `${this.addCiYmlPath}&template=${template.key}`,
                description: sprintf(this.$options.i18n.description, { name: template.name }),
              });
            }

            return templates;
          }, []);
        })
        .catch(() => {})
        .finally(() => {
          this.isLoading = false;
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
      <gl-loading-icon />
    </div>

    <ul class="gl-list-style-none gl-pl-0">
      <li v-for="template in templates" :key="template.key">
        <div
          class="gl-display-flex gl-align-items-center gl-justify-content-space-between gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-pb-5 gl-pt-5"
        >
          <div class="gl-display-flex gl-flex-direction-row gl-align-items-center">
            <img width="48" height="48" :src="template.logoPath" class="gl-mr-6" />
            <div class="gl-flex-direction-row">
              <strong class="gl-text-gray-800">{{ template.name }}</strong>
              <p class="gl-mb-0">{{ template.description }}</p>
            </div>
          </div>
          <gl-button category="primary" variant="confirm" :href="template.link">{{
            $options.i18n.cta
          }}</gl-button>
        </div>
      </li>
    </ul>
  </div>
</template>
