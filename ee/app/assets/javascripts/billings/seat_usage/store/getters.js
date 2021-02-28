export const tableItems = (state) => {
  if (state.members.length) {
    return state.members.map(
      ({ id, name, username, avatar_url, web_url, email, last_activity_on }) => {
        const formattedUserName = `@${username}`;

        return {
          user: {
            id,
            name,
            username: formattedUserName,
            avatar_url,
            web_url,
            lastActivityOn: last_activity_on,
          },
          email,
        };
      },
    );
  }
  return [];
};
