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

export const frameworkFoundResponse = {
  id: 'gid://gitlab/ComplianceManagement::Framework/1',
  name: 'GDPR',
  description: 'General Data Protection Regulation',
  color: '#1aaa55',
  parsedId: 1,
};

export const validFetchOneResponse = {
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
        ],
        __typename: 'ComplianceFrameworkConnection',
      },
      __typename: 'Namespace',
    },
  },
};

export const validCreateResponse = {
  data: {
    createComplianceFramework: {
      framework: {
        id: 'gid://gitlab/ComplianceManagement::Framework/1',
        name: 'GDPR',
        description: 'General Data Protection Regulation',
        color: '#1aaa55',
        __typename: 'ComplianceFramework',
      },
      errors: [],
      __typename: 'CreateComplianceFrameworkPayload',
    },
  },
};

export const errorCreateResponse = {
  data: {
    createComplianceFramework: {
      framework: null,
      errors: ['Invalid values given'],
      __typename: 'CreateComplianceFrameworkPayload',
    },
  },
};

export const validUpdateResponse = {
  data: {
    updateComplianceFramework: {
      clientMutationId: null,
      errors: [],
      __typename: 'UpdateComplianceFrameworkPayload',
    },
  },
};

export const errorUpdateResponse = {
  data: {
    updateComplianceFramework: {
      clientMutationId: null,
      errors: ['Invalid values given'],
      __typename: 'UpdateComplianceFrameworkPayload',
    },
  },
};
