export const validFetchResponse = {
  data: {
    namespace: {
      id: 'gid://gitlab/Group/1',
      name: 'Group 1',
      complianceFrameworks: {
        nodes: [
          {
            id: 'gid://gitlab/ComplianceManagement::Framework/1',
            name: 'GDPR',
            description: 'General Data Protection Regulation',
            color: '#1aaa55',
            __typename: 'ComplianceFramework',
          },
          {
            id: 'gid://gitlab/ComplianceManagement::Framework/2',
            name: 'PCI-DSS',
            description: 'Payment Card Industry-Data Security Standard',
            color: '#6666c4',
            __typename: 'ComplianceFramework',
          },
        ],
        __typename: 'ComplianceFrameworkConnection',
      },
      __typename: 'Namespace',
    },
  },
};

export const emptyFetchResponse = {
  data: {
    namespace: {
      id: 'gid://group-1/Group/1',
      name: 'Group 1',
      complianceFrameworks: {
        nodes: [],
        __typename: 'ComplianceFrameworkConnection',
      },
      __typename: 'Namespace',
    },
  },
};
