export const suggestedLabelColors = {
  '#000000': 'Black',
  '#0033CC': 'UA blue',
  '#428BCA': 'Moderate blue',
  '#44AD8E': 'Lime green',
};

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
            pipelineConfigurationFullPath: 'file.yml@group/project',
            color: '#1aaa55',
            __typename: 'ComplianceFramework',
          },
          {
            id: 'gid://gitlab/ComplianceManagement::Framework/2',
            name: 'PCI-DSS',
            description: 'Payment Card Industry-Data Security Standard',
            pipelineConfigurationFullPath: 'file.yml@group/project',
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
  pipelineConfigurationFullPath: 'file.yml@group/project',
  color: '#1aaa55',
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
            pipelineConfigurationFullPath: 'file.yml@group/project',
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
        pipelineConfigurationFullPath: 'file.yml@group/project',
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

export const validDeleteResponse = {
  data: {
    destroyComplianceFramework: {
      clientMutationId: null,
      errors: [],
      __typename: 'DestroyComplianceFrameworkPayload',
    },
  },
};

export const errorDeleteResponse = {
  data: {
    destroyComplianceFramework: {
      clientMutationId: null,
      errors: ['graphql error'],
      __typename: 'DestroyComplianceFrameworkPayload',
    },
  },
};
