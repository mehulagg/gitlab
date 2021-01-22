<script>
import { mapActions, mapState } from 'vuex';
import {
  GlButton,
  GlSprintf,
  GlLink,
  GlIcon,
  GlFormGroup,
  GlFormInput,
  GlFormCheckbox,
} from '@gitlab/ui';
import { mapComputed } from '~/vuex_shared/bindings';
import { __, s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlSprintf,
    GlLink,
    GlFormGroup,
    GlFormInput,
    GlIcon,
    GlFormCheckbox,
  },
  i18n: {
    headerText: s__('StatusPage|Status page'),
    expandBtnLabel: __('Expand'),
    saveBtnLabel: __('Save changes'),
    subHeaderText: s__(
      'StatusPage|Configure file storage settings to link issues in this project to an external status page.',
    ),
    introText: s__(
      'StatusPage|To publish incidents to an external status page, GitLab will store a JSON file in your Amazon S3 account in a location accessible to your external status page service. Make sure to also set up %{docsLink}',
    ),
    introLinkText: s__('StatusPage|your status page frontend.'),
    activeLabel: s__('StatusPage|Active'),
    url: {
      label: s__('StatusPage|Status page URL'),
      linkText: s__('StatusPage|Status page frontend documentation'),
    },
    bucket: {
      label: s__('StatusPage|S3 Bucket name'),
      helpText: s__('StatusPage|Bucket %{docsLink}'),
      linkText: s__('StatusPage|configuration documentation'),
    },
    region: {
      label: s__('StatusPage|AWS region'),
      helpText: s__('StatusPage|For help with configuration, visit %{docsLink}'),
      linkText: s__('StatusPage|AWS documentation'),
    },
    accessKey: {
      label: s__('StatusPage|AWS access key ID'),
    },
    secretAccessKey: {
      label: s__('StatusPage|AWS Secret access key'),
    },
  },
  computed: {
    ...mapState(['loading']),
    ...mapComputed([
      { key: 'enabled', updateFn: 'setStatusPageEnabled' },
      { key: 'url', updateFn: 'setStatusPageUrl' },
      { key: 'bucketName', updateFn: 'setStatusPageBucketName' },
      { key: 'region', updateFn: 'setStatusPageRegion' },
      { key: 'awsAccessKey', updateFn: 'setStatusPageAccessKey' },
      { key: 'awsSecretKey', updateFn: 'setStatusPageSecretAccessKey' },
    ]),
  },
  methods: {
    ...mapActions(['updateStatusPageSettings']),
  },
};
</script>

<template>
  <section id="status-page" class="settings no-animate js-status-page-settings">
    <div class="settings-header">
      <h4 ref="sectionHeader">
        {{ $options.i18n.headerText }}
      </h4>
      <gl-button ref="toggleBtn" class="js-settings-toggle">{{
        $options.i18n.expandBtnLabel
      }}</gl-button>
      <p ref="sectionSubHeader">
        {{ $options.i18n.subHeaderText }}
      </p>
    </div>

    <div class="settings-content">
      <!-- eslint-disable @gitlab/vue-require-i18n-attribute-strings -->
      <p>
        <gl-sprintf :message="$options.i18n.introText">
          <template #docsLink>
            <gl-link href="/help/user/project/status_page/index.html">
              <span>{{ $options.i18n.introLinkText }}</span>
            </gl-link>
          </template>
        </gl-sprintf>
      </p>
      <form ref="settingsForm" @submit.prevent="updateStatusPageSettings">
        <gl-form-group class="gl-pl-0 mb-3">
          <gl-form-checkbox v-model="enabled">
            <span class="bold">{{ $options.i18n.activeLabel }}</span></gl-form-checkbox
          >
        </gl-form-group>

        <gl-form-group
          :label="$options.i18n.url.label"
          label-size="sm"
          label-for="status-page-url"
          class="col-8 col-md-9 gl-pl-0 mb-3"
        >
          <gl-form-input id="status-page-url" v-model="url" />
          <p class="form-text text-muted">
            <gl-link href="/help/user/project/status_page/index.html">
              {{ $options.i18n.url.linkText }}
            </gl-link>
          </p>
        </gl-form-group>

        <gl-form-group
          :label="$options.i18n.bucket.label"
          label-size="sm"
          label-for="status-page-s3-bucket-name"
          class="col-8 col-md-9 gl-pl-0 mb-3"
        >
          <gl-form-input id="status-page-s3-bucket-name" v-model="bucketName" />
          <p class="form-text text-muted">
            <gl-sprintf :message="$options.i18n.bucket.helpText">
              <template #docsLink>
                <gl-link
                  target="_blank"
                  href="https://docs.aws.amazon.com/AmazonS3/latest/dev/HostingWebsiteOnS3Setup.html"
                >
                  <span>{{ $options.i18n.bucket.linkText }}</span>
                  <gl-icon name="external-link" class="vertical-align-middle" />
                </gl-link>
              </template>
            </gl-sprintf>
          </p>
        </gl-form-group>

        <gl-form-group
          :label="$options.i18n.region.label"
          label-size="sm"
          label-for="status-page-aws-region"
          class="col-8 col-md-9 gl-pl-0 mb-3"
        >
          <gl-form-input
            id="status-page-aws-region"
            v-model="region"
            placeholder="example: us-west-2"
          />
          <p class="form-text text-muted">
            <gl-sprintf :message="$options.i18n.region.helpText">
              <template #docsLink>
                <gl-link href="https://github.com/aws/aws-sdk-ruby#configuration" target="_blank">
                  <span>{{ $options.i18n.region.linkText }}</span>
                  <gl-icon name="external-link" class="vertical-align-middle" />
                </gl-link>
              </template>
            </gl-sprintf>
          </p>
        </gl-form-group>

        <gl-form-group
          :label="$options.i18n.accessKey.label"
          label-size="sm"
          label-for="status-page-aws-access-key"
          class="col-8 col-md-9 gl-pl-0 mb-3"
        >
          <gl-form-input id="status-page-aws-access-key " v-model="awsAccessKey" />
        </gl-form-group>

        <gl-form-group
          :label="$options.i18n.secretAccessKey.label"
          label-size="sm"
          label-for="status-page-aws-secret-access-key"
          class="col-8 col-md-9 gl-pl-0 mb-3"
        >
          <gl-form-input id="status-page-aws-secret-access-key " v-model="awsSecretKey" />
        </gl-form-group>
        <gl-button
          ref="submitBtn"
          :disabled="loading"
          variant="success"
          category="primary"
          type="submit"
          class="js-no-auto-disable"
        >
          {{ $options.i18n.saveBtnLabel }}
        </gl-button>
      </form>
    </div>
  </section>
</template>
