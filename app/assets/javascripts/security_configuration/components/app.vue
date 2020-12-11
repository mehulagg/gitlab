<script>
import { GlLink, GlSprintf, GlTable } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

export default {
  components: {
    GlLink,
    GlSprintf,
    GlTable
  },
  data: () => ({
    features: [
      {
        manage: 'Enable via Merge Request',
        name: 'Static Application Security Testing (SAST)',
        description: 'Analyze your source code for known vulnerabilities.',
        link: 'user/application_security/sast/index',
        type: 'sast'
      },
      {
        manage: 'Available with upgrade or free trial',
        name: 'Dynamic Application Security Testing (DAST)',
        description: 'Analyze a review version of your web application.',
        link: 'user/application_security/dast/index',
        type: 'dast'
      },
      {
        manage: '',
        name: 'Secret Detection',
        description: 'Analyze your source code and git history for secrets.',
        link: 'user/application_security/secret_detection/index',
        // fix me use imported constants
        type: 'secret_detection'
      }
    ]
  }),
  computed: {
    fields() {
      const borderClasses = 'gl-border-b-1! gl-border-b-solid! gl-border-gray-100!';
      const thClass = `gl-text-gray-900 gl-bg-transparent! ${borderClasses}`;

      return [
        {
          key: 'feature',
          label: s__('SecurityConfiguration|Security Control'),
          thClass,
        },        
        {
          key: 'manage',
          label: s__('SecurityConfiguration|Manage'),
          thClass,
        },
      ];
    }
  },
  methods: {
    getFeatureDocumentationLinkLabel(item) {
      return sprintf(s__('SecurityConfiguration|Feature documentation for %{featureName}'), {
        featureName: item.name,
      });
    },
    getComponentForItem(item) {
      const COMPONENTS = {
        sast: ManageSast,
        secret_detection: ManageSecretDetection,
        dast: ManageDast
      };
      
      return COMPONENTS[item.type];

    }
  }
};
</script>

<template>
  <article>
    <header>
      <h4 class="my-3">{{ __('Security Configuration') }}</h4>
      <h5 class="gl-font-lg mt-5">{{ s__('SecurityConfiguration|Testing & Compliance') }}</h5>
    </header>

    <gl-table ref="securityControlTable" :items="features" :fields="fields" stacked="md">
      <template #cell(feature)="{ item }">
        <div class="gl-text-gray-900">{{ item.name }}</div>
        <div>
          {{ item.description }}
          <gl-link
            target="_blank"
            :href="item.link"
            :aria-label="getFeatureDocumentationLinkLabel(item)"
            data-testid="docsLink"
          >
            {{ s__('SecurityConfiguration|More information') }}
          </gl-link>
        </div>
      </template>

      <template #cell(manage)="{ item }">
        <component :is="getComponentForItem(item)" :item="item"></component>
      </template>
    </gl-table>
  </article>
</template>
