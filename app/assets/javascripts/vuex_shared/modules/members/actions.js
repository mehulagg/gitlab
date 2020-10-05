import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';

export const updateMemberRole = async ({ state, commit }, { memberId, accessLevel }) => {
  try {
    const promise = await axios.put(
      state.memberPath.replace(':id', memberId),
      state.requestFormatter({ accessLevel: accessLevel.integerValue }),
    );

    commit(types.RECEIVE_MEMBER_ROLE_SUCCESS, { memberId, accessLevel });

    return promise;
  } catch (error) {
    commit(types.RECEIVE_MEMBER_ROLE_ERROR);

    throw error;
  }
};
