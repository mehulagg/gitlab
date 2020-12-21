export const mockLabels = [
  {
    id: 26,
    title: 'Foo Label',
    description: 'Foobar',
    color: '#BADA55',
    text_color: '#FFFFFF',
  },
  {
    id: 27,
    title: 'Foo::Bar',
    description: 'Foobar',
    color: '#0033CC',
    text_color: '#FFFFFF',
  },
];

export const mockSuggestedColors = {
  '#273be2': 'Palatinate blue',
  '#007bb8': 'Star command blue',
  '#29ab87': 'Jungle green',
  '#addfad': 'Light moss green',
  '#74c365': 'Mantis',
  '#84de02': 'Alien armpit',
  '#195905': 'Lincoln green',
  '#36454f': 'Charcoal grey',
  '#848482': 'Old silver',
  '#b19cd9': 'Light pastel purple',
  '#512888': 'KSU purple',
  '#9a4eae': 'Purpureus',
  '#f7e7ce': 'Champagne',
  '#b3446c': 'Raspberry rose',
  '#da1d81': 'Vivid cerise',
  '#CC0033': 'Vivid crimson',
  '#FF0000': 'Red',
  '#cc4e5c': 'Dark terra cotta',
  '#e4d00a': 'Citrine',
  '#ffb347': 'Pastel orange',
  '#c39953': 'Aztec gold',
};

export const mockConfig = {
  showCreate: true,
  isProject: true,
  abilityName: 'issue',
  context: {
    labels: mockLabels,
  },
  namespace: 'gitlab-org',
  updatePath: '/gitlab-org/my-project/issue/1',
  labelsPath: '/gitlab-org/my-project/-/labels.json',
  labelsWebUrl: '/gitlab-org/my-project/-/labels',
  labelFilterBasePath: '/gitlab-org/my-project/issues',
  canEdit: true,
  suggestedColors: mockSuggestedColors,
  emptyValueText: 'None',
};
