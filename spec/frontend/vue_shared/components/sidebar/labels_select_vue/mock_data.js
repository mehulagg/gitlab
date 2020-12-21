export const mockRegularLabel = {
  id: 26,
  title: 'Foo Label',
  description: 'Foobar',
  color: '#BADA55',
  textColor: '#FFFFFF',
};

export const mockScopedLabel = {
  id: 27,
  title: 'Foo::Bar',
  description: 'Foobar',
  color: '#0033CC',
  textColor: '#FFFFFF',
};

export const mockLabels = [
  mockRegularLabel,
  mockScopedLabel,
  {
    id: 28,
    title: 'Bug',
    description: 'Label for bugs',
    color: '#FF0000',
    textColor: '#FFFFFF',
  },
  {
    id: 29,
    title: 'Boog',
    description: 'Label for bugs',
    color: '#FF0000',
    textColor: '#FFFFFF',
  },
];

export const mockConfig = {
  allowLabelEdit: true,
  allowLabelCreate: true,
  allowScopedLabels: true,
  allowMultiselect: true,
  labelsListTitle: 'Assign labels',
  labelsCreateTitle: 'Create label',
  variant: 'sidebar',
  dropdownOnly: false,
  selectedLabels: [mockRegularLabel, mockScopedLabel],
  labelsSelectInProgress: false,
  labelsFetchPath: '/gitlab-org/my-project/-/labels.json',
  labelsManagePath: '/gitlab-org/my-project/-/labels',
  labelsFilterBasePath: '/gitlab-org/my-project/issues',
};

export const mockSuggestedColors = {
  '#273be2': 'Palatinate blue',
  '#007bb8': 'Star command blue',
  '#29ab87': 'Jungle green',
  '#addfad': 'Light moss green',
  '#74c365': 'Mantis',
  '#84de02': 'Alien armpit',
  '#195905': 'Lincoln green',
  '#36454f': 'Charcoal grey',
  '#848482': 'Old Silver',
  '#b19cd9': 'Light pastel purple',
  '#512888': 'KSU Purple ',
  '#9a4eae': 'Purpureus',
  '#f7e7ce': 'Champagne',
  '#b3446c': 'Raspberry rose',
  '#da1d81': 'Vivid cerise',
  '#CC0033': 'Vivid crimson',
  '#FF0000': 'Red',
  '#cc4e5c': 'Dark terra cotta',
  '#e4d00a': 'Citrine',
  '#ffb347': 'Pastel orange',
  '#c39953': 'Aztec Gold',
};
