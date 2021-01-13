export const tableItems = (state) => {
  if (state.members.length) {
    return state.members.map(({ name, username, avatar_url, web_url, email }) => {
      const formattedUserName = `@${username}`;

      return { user: { name, username: formattedUserName, avatar_url, web_url }, email };
    });
  }
  return [];
};
