// TODO: Should we move this file so it's not in the `doc` directory? :thinking:
import gitlabSchemaStr from '../../../../../doc/api/graphql/reference/gitlab_schema.graphql';

import { mockServer } from 'graphql-mock-factory';

// TODO: Instead of hardcoding the query as a string, let's use the real
// query instead. We just need to figure out how to inject variable into the query.
import getGroupPackagesSettingsQuery from '~/packages_and_registries/settings/group/graphql/queries/get_group_packages_settings.query.graphql';

// TODO: Is this the correct way to mock this value? Or should
// we globally auto-mock the `Types::UntrustedRegexp` type somehow?
const mocks = {
  PackageSettings: {
    mavenDuplicateExceptionRegex: () => '',
  },
};

const mockedServer = mockServer(gitlabSchemaStr.loc.source.body, mocks);

// TODO: Replace with `getGroupPackagesSettingsQuery` imported above
const query = `{
  group(fullPath: "fullPath") {
    __typename
    packageSettings {
      __typename
      mavenDuplicatesAllowed
      mavenDuplicateExceptionRegex
    }
  }
}`;

export const groupPackageSettingsMock = mockedServer(query);
