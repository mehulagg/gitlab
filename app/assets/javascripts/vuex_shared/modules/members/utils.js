import Vue from 'vue';

export const findAndUpdateMember = (state, memberId, propertyName, value) => {
  const index = state.members.findIndex(member => member.id === memberId);

  if (index === -1) {
    return;
  }

  const member = state.members[index];
  Vue.set(member, propertyName, value);

  state.members.splice(index, 1, member);
};
