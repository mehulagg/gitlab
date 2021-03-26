// This represents a top-level GraphQL error and therefore can't be
// auto mocked since it isn't part of the schema.
export const groupPackageSettingsMutationGraphQLError = {
  message:
    'Variable $input of type UpdateNamespacePackageSettingsInput! was provided invalid value for mavenDuplicateExceptionRegex (latest[master]somethingj)) is an invalid regexp: unexpected ): latest[master]somethingj)))',
  locations: [{ line: 1, column: 41 }],
  extensions: {
    value: {
      namespacePath: 'gitlab-org',
      mavenDuplicateExceptionRegex: 'latest[master]something))',
    },
    problems: [
      {
        path: ['mavenDuplicateExceptionRegex'],
        explanation:
          'latest[master]somethingj)) is an invalid regexp: unexpected ): latest[master]something))',
        message:
          'latest[master]somethingj)) is an invalid regexp: unexpected ): latest[master]something))',
      },
    ],
  },
};
