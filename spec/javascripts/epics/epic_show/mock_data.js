export const mockLabels = [
  {
    id: 26,
    title: 'Foo Label',
    description: 'Foobar',
    color: '#BADA55',
    text_color: '#FFFFFF',
  },
];

export const mockParticipants = [
  {
    id: 1,
    name: 'Administrator',
    username: 'root',
    state: 'active',
    avatar_url: '',
    web_url: 'http://127.0.0.1:3001/root',
  },
  {
    id: 12,
    name: 'Susy Johnson',
    username: 'tana_harvey',
    state: 'active',
    avatar_url: '',
    web_url: 'http://127.0.0.1:3001/tana_harvey',
  },
];

export const contentProps = {
  endpoint: '',
  toggleSubscriptionPath: gl.TEST_HOST,
  updateEndpoint: gl.TEST_HOST,
  canAdmin: true,
  canUpdate: true,
  canDestroy: true,
  markdownPreviewPath: '',
  markdownDocsPath: '',
  issueLinksEndpoint: '/',
  groupPath: '',
  namespace: 'gitlab-org',
  labelsPath: '',
  labelsWebUrl: '',
  epicsWebUrl: '',
  initialTitleHtml: '',
  initialTitleText: '',
  startDate: '2017-01-01',
  endDate: '2017-10-10',
  labels: mockLabels,
  participants: mockParticipants,
  subscribed: true,
};

export const headerProps = {
  author: {
    url: `${gl.TEST_HOST}/url`,
    src: `${gl.TEST_HOST}/image`,
    username: '@root',
    name: 'Administrator',
  },
  created: (new Date()).toISOString(),
};

export const props = Object.assign({}, contentProps, headerProps);
