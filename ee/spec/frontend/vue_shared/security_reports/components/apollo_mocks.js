export const vulnerabilityExternalIssueLinkCreateMockFactory = ({ errors = [] } = {}) => ({
  data: {
    vulnerabilityExternalIssueLinkCreate: {
      errors,
      externalIssueLink: {
        externalIssue: {
          webUrl: 'http://foo.bar',
        },
      },
    },
  },
});
