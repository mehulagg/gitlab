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
  '#0033CC': 'Blue',
  '#428BCA': 'Blue gray',
  '#44AD8E': 'Green cyan',
  '#A8D695': 'Sea green',
  '#5CB85C': 'Desaturated green',
  '#69D100': 'Bright green',
  '#004E00': 'Dark green',
  '#34495E': 'Steel blue',
  '#7F8C8D': 'Gray',
  '#A295D6': 'Lavender',
  '#5843AD': 'Violet',
  '#8E44AD': 'Purple',
  '#FFECDB': 'Champagne',
  '#AD4363': 'Rose',
  '#D10069': 'Strong pink',
  '#CC0033': 'Crimson',
  '#FF0000': 'Red',
  '#D9534F': 'Dark coral',
  '#D1D100': 'Pear',
  '#F0AD4E': 'Soft orange',
  '#AD8D43': 'Soft brown',
};
