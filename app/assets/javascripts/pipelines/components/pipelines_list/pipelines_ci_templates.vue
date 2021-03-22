<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import Api from '~/api';
import { __ } from '~/locale';

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
  Go: { logo: 'go' },
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
  },
  props: {
    projectId: {
      type: String,
      required: true,
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
              });
            } else {
              return templates;
            }
          }, []);
        })
        .catch(() => console.log('ere'))
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

    <div v-if="this.isLoading">
      <gl-loading-icon />
    </div>

    <ul v-for="template in this.templates" :key="template.key">
      <li><img :src="template.logoPath" />{{ template.name }}</li>
    </ul>
  </div>
</template>
