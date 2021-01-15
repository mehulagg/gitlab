import axios from 'axios';

export const addSubscription = async (addPath, jwt, namespace) => {
  return axios.post(addPath, {
    jwt,
    namespace_path: namespace,
  });
};

export const removeSubscription = async (removePath, jwt) => {
  return axios.delete(removePath, {
    params: {
      jwt,
    },
  });
};

export const fetchGroups = async (groupsPath, { page, perPage }) => {
  return axios.get(groupsPath, {
    params: {
      page,
      per_page: perPage,
    },
  });
};
