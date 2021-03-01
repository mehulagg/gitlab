export const mockJiraIssue = {
  title_html:
    '<a href="https://jira.reali.sh:8080/projects/FE/issues/FE-2">FE-2</a> The second FE issue on Jira',
  description_html:
    '<a href="https://jira.reali.sh:8080/projects/FE/issues/FE-2">FE-2</a> The second FE issue on Jira',
  created_at: '"2021-02-01T04:04:40.833Z"',
  author: {
    name: 'Justin Ho',
    web_url: 'http://127.0.0.1:3000/root',
    avatar_url: 'http://127.0.0.1:3000/uploads/-/system/user/avatar/1/avatar.png?width=90',
  },
  assignees: [
    {
      name: 'Justin Ho',
      web_url: 'http://127.0.0.1:3000/root',
      avatar_url: 'http://127.0.0.1:3000/uploads/-/system/user/avatar/1/avatar.png?width=90',
    },
  ],
  labels: [
    {
      title: 'In Progress',
      description: 'Work that is still in progress',
      color: '#EBECF0',
      text_color: '#283856',
    },
  ],
  references: {
    relative: 'FE-2',
  },
  state: 'opened',
};
