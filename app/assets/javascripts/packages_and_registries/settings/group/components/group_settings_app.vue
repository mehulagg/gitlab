<script>
import { GlSprintf, GlLink, GlAlert } from '@gitlab/ui';
import SettingsBlock from '~/vue_shared/components/settings/settings_block.vue';
import MavenSettings from '~/packages_and_registries/settings/group/components/maven_settings.vue';

import {
  PACKAGE_SETTINGS_HEADER,
  PACKAGE_SETTINGS_DESCRIPTION,
  PACKAGES_DOCS_PATH,
  ERROR_UPDATING_SETTINGS,
  SUCCESS_UPDATING_SETTINGS,
} from '~/packages_and_registries/settings/group/constants';
import { updateGroupPackageSettings } from '~/packages_and_registries/settings/group/graphql/utils/cache_update';
import { updateGroupPackagesSettingsOptimisticResponse } from '~/packages_and_registries/settings/group/graphql/utils/optimistic_responses';
import getGroupPackagesSettingsQuery from '~/packages_and_registries/settings/group/graphql/queries/get_group_packages_settings.query.graphql';
import updateNamespacePackageSettings from '~/packages_and_registries/settings/group/graphql/mutations/update_group_packages_settings.mutation.graphql';

export default {
  name: 'GroupSettingsApp',
  i18n: {
    PACKAGE_SETTINGS_HEADER,
    PACKAGE_SETTINGS_DESCRIPTION,
  },
  links: {
    PACKAGES_DOCS_PATH,
  },
  components: {
    GlAlert,
    GlSprintf,
    GlLink,
    SettingsBlock,
    MavenSettings,
  },
  inject: ['defaultExpanded', 'groupPath'],
  apollo: {
    packageSettings: {
      query: getGroupPackagesSettingsQuery,
      variables() {
        return {
          fullPath: this.groupPath,
        };
      },
      update(data) {
        return data.group?.packageSettings;
      },
    },
  },
  data() {
    return {
      packageSettings: {},
      errors: {},
      alertConfig: null,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.packageSettings.loading;
    },
  },
  methods: {
    dismissAlert() {
      this.alertConfig = null;
    },
    updateSettings(payload) {
      this.errors = {};
      return this.$apollo
        .mutate({
          mutation: updateNamespacePackageSettings,
          variables: {
            input: {
              namespacePath: this.groupPath,
              ...payload,
            },
          },
          update: updateGroupPackageSettings(this.groupPath),
          optimisticResponse: updateGroupPackagesSettingsOptimisticResponse({
            ...this.packageSettings,
            ...payload,
          }),
        })
        .then(({ data }) => {
          if (data.updateNamespacePackageSettings?.errors?.length > 0) {
            this.alertConfig = { message: ERROR_UPDATING_SETTINGS, variant: 'warning' };
          } else {
            this.alertConfig = { message: SUCCESS_UPDATING_SETTINGS, variant: 'success' };
          }
        })
        .catch((e) => {
          if (e.graphQLErrors) {
            e.graphQLErrors.forEach((error) => {
              const [
                {
                  path: [key],
                  message,
                },
              ] = error.extensions.problems;
              this.errors = { ...this.errors, [key]: message };
            });
          }
          this.alertConfig = { message: ERROR_UPDATING_SETTINGS, variant: 'warning' };
        });
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="alertConfig"
      :variant="alertConfig.variant"
      class="gl-mt-4"
      @dismiss="dismissAlert"
    >
      {{ alertConfig.message }}
    </gl-alert>

    <settings-block :default-expanded="defaultExpanded">
      <template #title> {{ $options.i18n.PACKAGE_SETTINGS_HEADER }}</template>
      <template #description>
        <span data-testid="description">
          <gl-sprintf :message="$options.i18n.PACKAGE_SETTINGS_DESCRIPTION">
            <template #link="{ content }">
              <gl-link :href="$options.links.PACKAGES_DOCS_PATH" target="_blank">{{
                content
              }}</gl-link>
            </template>
          </gl-sprintf>
        </span>
      </template>
      <template #default>
        <maven-settings
          :maven-duplicates-allowed="packageSettings.mavenDuplicatesAllowed"
          :maven-duplicate-exception-regex="packageSettings.mavenDuplicateExceptionRegex"
          :maven-duplicate-exception-regex-error="errors.mavenDuplicateExceptionRegex"
          :loading="isLoading"
          @update="updateSettings"
          @focus="dismissAlert"
        />
      </template>
    </settings-block>
  </div>
</template>
