import produce from 'immer';

const addEscalationPolicyToStore = (store, query, { escalationPolicyCreate }, variables) => {
  const policy = escalationPolicyCreate?.escalationPolicy;
  if (!policy) {
    return;
  }

  const sourceData = store.readQuery({
    query,
    variables,
  });

  const data = produce(sourceData, (draftData) => {
    draftData.project.incidentManagementEscalationPolicies.nodes.push(policy);
  });

  store.writeQuery({
    query,
    variables,
    data,
  });
};

export const hasErrors = ({ errors = [] }) => errors?.length;

export const updateStoreOnEscalationPolicyCreate = (store, query, data, variables) => {
  if (!hasErrors(data)) {
    addEscalationPolicyToStore(store, query, data, variables);
  }
};
