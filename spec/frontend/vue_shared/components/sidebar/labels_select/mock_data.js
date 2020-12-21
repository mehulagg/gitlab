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
