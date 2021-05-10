export const tableItems = (state) => {
  if (state.members.length) {
    return state.members.map(
      ({ id, name, username, avatar_url, web_url, email, last_activity_on, membership_type }) => {
        const formattedUserName = `@${username}`;

        return {
          user: {
            id,
            name,
            username: formattedUserName,
            avatar_url,
            web_url,
            last_activity_on,
            membership_type,
          },
          email,
        };
      },
    );
  }
  return [];
};

export const membershipsById = (state) => (memberId) => {
  return state.userDetails[memberId] || { isLoading: true, items: [] };
};
