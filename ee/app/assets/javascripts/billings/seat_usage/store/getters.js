export const tableItems = (state) => {
  if (state.members.length) {
    return state.members.map(({ id, name, username, avatar_url, web_url, email }) => {
      const formattedUserName = `@${username}`;

      return { user: { id, name, username: formattedUserName, avatar_url, web_url }, email };
    });
  }
  return [];
};
