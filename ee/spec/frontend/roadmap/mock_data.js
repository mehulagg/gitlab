export const mockScrollBarSize = 15;

export const mockGroupId = 2;

export const mockShellWidth = 2000;

export const mockItemWidth = 180;

export const mockSortedBy = 'start_date_asc';

export const basePath = '/groups/gitlab-org/-/epics.json';

export const epicsPath = '/groups/gitlab-org/-/epics.json?start_date=2017-11-1&end_date=2018-4-30';

export const mockNewEpicEndpoint = '/groups/gitlab-org/-/epics';

export const mockSvgPath = '/foo/bar.svg';

export const mockTimeframeInitialDate = new Date(2018, 0, 1);

const defaultDescendantCounts = {
  openedEpics: 0,
  closedEpics: 0,
};

export const mockTimeframeQuartersPrepend = [
  {
    year: 2016,
    quarterSequence: 4,
    range: [new Date(2016, 9, 1), new Date(2016, 10, 1), new Date(2016, 11, 31)],
  },
  {
    year: 2017,
    quarterSequence: 1,
    range: [new Date(2017, 0, 1), new Date(2017, 1, 1), new Date(2017, 2, 31)],
  },
  {
    year: 2017,
    quarterSequence: 2,
    range: [new Date(2017, 3, 1), new Date(2017, 4, 1), new Date(2017, 5, 30)],
  },
];
export const mockTimeframeQuartersAppend = [
  {
    year: 2019,
    quarterSequence: 2,
    range: [new Date(2019, 3, 1), new Date(2019, 4, 1), new Date(2019, 5, 30)],
  },
  {
    year: 2019,
    quarterSequence: 3,
    range: [new Date(2019, 6, 1), new Date(2019, 7, 1), new Date(2019, 8, 30)],
  },
  {
    year: 2019,
    quarterSequence: 4,
    range: [new Date(2019, 9, 1), new Date(2019, 10, 1), new Date(2019, 11, 31)],
  },
];

export const mockTimeframeMonthsPrepend = [
  new Date(2017, 2, 1),
  new Date(2017, 3, 1),
  new Date(2017, 4, 1),
  new Date(2017, 5, 1),
  new Date(2017, 6, 1),
  new Date(2017, 7, 1),
  new Date(2017, 8, 1),
  new Date(2017, 9, 1),
];
export const mockTimeframeMonthsAppend = [
  new Date(2018, 6, 1),
  new Date(2018, 7, 1),
  new Date(2018, 8, 1),
  new Date(2018, 9, 1),
  new Date(2018, 10, 1),
  new Date(2018, 11, 31),
];

export const mockTimeframeWeeksPrepend = [
  new Date(2017, 10, 5),
  new Date(2017, 10, 12),
  new Date(2017, 10, 19),
  new Date(2017, 10, 26),
  new Date(2017, 11, 3),
  new Date(2017, 11, 10),
];
export const mockTimeframeWeeksAppend = [
  new Date(2018, 0, 28),
  new Date(2018, 1, 4),
  new Date(2018, 1, 11),
  new Date(2018, 1, 18),
  new Date(2018, 1, 25),
  new Date(2018, 2, 4),
];

export const mockEpic = {
  id: 1,
  iid: 1,
  description:
    'Explicabo et soluta minus praesentium minima ab et voluptatem. Quas architecto vero corrupti voluptatibus labore accusantium consectetur. Aliquam aut impedit voluptates illum molestias aut harum. Aut non odio praesentium aut.\n\nQuo asperiores aliquid sed nobis. Omnis sint iste provident numquam. Qui voluptatem tempore aut aut voluptas dolorem qui.\n\nEst est nemo quod est. Odit modi eos natus cum illo aut. Expedita nostrum ea est omnis magnam ut eveniet maxime. Itaque ipsam provident minima et occaecati ut. Dicta est perferendis sequi perspiciatis rerum voluptatum deserunt.',
  title:
    'Cupiditate exercitationem unde harum reprehenderit maxime eius velit recusandae incidunt quia.',
  groupId: 2,
  groupName: 'Gitlab Org',
  groupFullName: 'Gitlab Org',
  startDate: new Date('2017-07-10'),
  originalStartDate: new Date('2017-07-10'),
  endDate: new Date('2018-06-02'),
  webUrl: '/groups/gitlab-org/-/epics/1',
  descendantCounts: {
    openedEpics: 3,
    closedEpics: 2,
  },
};

export const mockRawEpic = {
  id: 41,
  iid: 2,
  description: null,
  title: 'Another marketing',
  group_id: 56,
  group_name: 'Marketing',
  group_full_name: 'Gitlab Org / Marketing',
  start_date: '2017-6-26',
  end_date: '2018-03-10',
  web_url: '/groups/gitlab-org/marketing/-/epics/2',
  descendantCounts: {
    openedEpics: 3,
    closedEpics: 2,
  },
  group: {
    fullPath: '/groups/gitlab-org/marketing/',
  },
};

export const mockFormattedChildEpic1 = {
  id: 50,
  iid: 52,
  description: null,
  title: 'Marketing child epic 1',
  groupId: 56,
  groupName: 'Marketing',
  groupFullName: 'Gitlab Org / Marketing',
  startDate: new Date(2017, 10, 1),
  originalStartDate: new Date(2017, 5, 26),
  endDate: new Date(2018, 2, 10),
  originalEndDate: new Date(2018, 2, 10),
  startDateOutOfRange: true,
  endDateOutOfRange: false,
  webUrl: '/groups/gitlab-org/marketing/-/epics/5',
  newEpic: undefined,
  descendantWeightSum: {
    closedIssues: 3,
    openedIssues: 2,
  },
  descendantCounts: defaultDescendantCounts,
  isChildEpic: true,
};

export const mockFormattedChildEpic2 = {
  id: 51,
  iid: 53,
  description: null,
  title: 'Marketing child epic 2',
  groupId: 56,
  groupName: 'Marketing',
  groupFullName: 'Gitlab Org / Marketing',
  startDate: new Date(2017, 10, 1),
  originalStartDate: new Date(2017, 5, 26),
  endDate: new Date(2018, 2, 10),
  originalEndDate: new Date(2018, 2, 10),
  startDateOutOfRange: true,
  endDateOutOfRange: false,
  webUrl: '/groups/gitlab-org/marketing/-/epics/6',
  newEpic: undefined,
  descendantWeightSum: {
    closedIssues: 3,
    openedIssues: 2,
  },
  isChildEpic: true,
};

export const mockFormattedEpic = {
  id: 41,
  iid: 2,
  description: null,
  title: 'Another marketing',
  groupId: 56,
  groupName: 'Marketing',
  groupFullName: 'Gitlab Org / Marketing',
  startDate: new Date(2017, 10, 1),
  originalStartDate: new Date(2017, 5, 26),
  endDate: new Date(2018, 2, 10),
  originalEndDate: new Date(2018, 2, 10),
  startDateOutOfRange: true,
  endDateOutOfRange: false,
  webUrl: '/groups/gitlab-org/marketing/-/epics/2',
  newEpic: undefined,
  descendantWeightSum: {
    closedIssues: 3,
    openedIssues: 2,
  },
  descendantCounts: {
    openedEpics: 3,
    closedEpics: 2,
  },
  isChildEpic: false,
  group: {
    fullPath: '/groups/gitlab-org/marketing/',
  },
};

export const rawEpics = [
  {
    id: 41,
    iid: 2,
    description: null,
    title: 'Another marketing',
    group_id: 56,
    group_name: 'Marketing',
    group_full_name: 'Gitlab Org / Marketing',
    start_date: '2017-12-26',
    end_date: '2018-03-10',
    web_url: '/groups/gitlab-org/marketing/-/epics/2',
    descendantCounts: defaultDescendantCounts,
    hasParent: true,
    parent: {
      id: '40',
    },
  },
  {
    id: 40,
    iid: 1,
    description: null,
    title: 'Marketing epic',
    group_id: 56,
    group_name: 'Marketing',
    group_full_name: 'Gitlab Org / Marketing',
    start_date: '2017-12-25',
    end_date: '2018-03-09',
    web_url: '/groups/gitlab-org/marketing/-/epics/1',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 39,
    iid: 12,
    description: null,
    title: 'Epic with end in first timeframe month',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-04-02',
    end_date: '2017-11-30',
    web_url: '/groups/gitlab-org/-/epics/12',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 38,
    iid: 11,
    description: null,
    title: 'Epic with end date out of range',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2018-01-15',
    end_date: '2020-01-03',
    web_url: '/groups/gitlab-org/-/epics/11',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 37,
    iid: 10,
    description: null,
    title: 'Epic with timeline in same month',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2018-01-01',
    end_date: '2018-01-31',
    web_url: '/groups/gitlab-org/-/epics/10',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 35,
    iid: 8,
    description: null,
    title: 'Epic with out of range start & null end',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-09-04',
    end_date: null,
    web_url: '/groups/gitlab-org/-/epics/8',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 33,
    iid: 6,
    description: null,
    title: 'Epic with only start date',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-11-27',
    end_date: null,
    web_url: '/groups/gitlab-org/-/epics/6',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 4,
    iid: 4,
    description:
      'Animi dolorem error ipsam assumenda. Dolor reprehenderit sit soluta molestias id. Explicabo vel dolores numquam earum ut aliquid. Quisquam aliquam a totam laborum quia.\n\nEt voluptatem reiciendis qui cum. Labore ratione delectus minus et voluptates. Dolor voluptatem nisi neque fugiat ut ullam dicta odit. Aut quaerat provident ducimus aut molestiae hic esse.\n\nSuscipit non repellat laudantium quaerat. Voluptatum dolor explicabo vel illo earum. Laborum vero occaecati qui autem cumque dolorem autem. Enim voluptatibus a dolorem et.',
    title: 'Et repellendus quo et laboriosam corrupti ex nisi qui.',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2018-01-01',
    end_date: '2018-02-02',
    web_url: '/groups/gitlab-org/-/epics/4',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 3,
    iid: 3,
    description:
      'Magnam placeat ut esse aut vel. Et sit ab soluta ut eos et et. Nesciunt expedita sit et optio maiores quas facilis. Provident ut aut et nihil. Nesciunt ipsum fuga labore dolor quia.\n\nSit suscipit impedit aut dolore non provident. Nesciunt nemo excepturi voluptatem natus veritatis. Vel ut possimus reiciendis dolorem et. Recusandae voluptatem voluptatum aut iure. Sapiente quia est iste similique quidem quia omnis et.\n\nId aut assumenda beatae iusto est dicta consequatur. Tempora voluptatem pariatur ab velit vero ut reprehenderit fuga. Dolor modi aspernatur eos atque eveniet harum sed voluptatem. Dolore iusto voluptas dolor enim labore dolorum consequatur dolores.',
    title: 'Nostrum ut nisi fugiat accusantium qui velit dignissimos.',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-12-01',
    end_date: '2018-03-26',
    web_url: '/groups/gitlab-org/-/epics/3',
    descendantCounts: defaultDescendantCounts,
    hasParent: true,
    parent: {
      id: '40',
    },
  },
  {
    id: 2,
    iid: 2,
    description:
      'Deleniti id facere numquam cum consectetur sint ipsum consequatur. Odit nihil harum consequuntur est nemo adipisci. Incidunt suscipit voluptatem et culpa at voluptatem consequuntur. Rerum aliquam earum quia consequatur ipsam quae ut.\n\nQuod molestias ducimus quia ratione nostrum ut adipisci. Fugiat officiis reiciendis repellendus quia ut ipsa. Voluptatum ut dolor perferendis nostrum. Porro a ducimus sequi qui quos ea. Earum velit architecto necessitatibus at dicta.\n\nModi aut non fugiat autem doloribus nobis ea. Sit quam corrupti blanditiis nihil tempora ratione enim ex. Aliquam quia ut impedit ut velit reprehenderit quae amet. Unde quod at dolorum eligendi in ducimus perspiciatis accusamus.',
    title: 'Sit beatae amet quaerat consequatur non repudiandae qui.',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-11-26',
    end_date: '2018-03-22',
    web_url: '/groups/gitlab-org/-/epics/2',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 1,
    iid: 1,
    description:
      'Explicabo et soluta minus praesentium minima ab et voluptatem. Quas architecto vero corrupti voluptatibus labore accusantium consectetur. Aliquam aut impedit voluptates illum molestias aut harum. Aut non odio praesentium aut.\n\nQuo asperiores aliquid sed nobis. Omnis sint iste provident numquam. Qui voluptatem tempore aut aut voluptas dolorem qui.\n\nEst est nemo quod est. Odit modi eos natus cum illo aut. Expedita nostrum ea est omnis magnam ut eveniet maxime. Itaque ipsam provident minima et occaecati ut. Dicta est perferendis sequi perspiciatis rerum voluptatum deserunt.',
    title:
      'Cupiditate exercitationem unde harum reprehenderit maxime eius velit recusandae incidunt quia.',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-07-10',
    end_date: '2018-06-02',
    web_url: '/groups/gitlab-org/-/epics/1',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 22,
    iid: 2,
    description: null,
    title: 'Epic with invalid dates',
    group_id: 56,
    group_name: 'Marketing',
    group_full_name: 'Gitlab Org / Marketing',
    start_date: '2018-12-26',
    end_date: '2018-03-10',
    web_url: '/groups/gitlab-org/marketing/-/epics/22',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
];

export const mockUnsortedEpics = [
  {
    startDate: new Date(2017, 2, 12),
    endDate: new Date(2017, 7, 20),
  },
  {
    startDate: new Date(2015, 5, 8),
    endDate: new Date(2016, 3, 1),
  },
  {
    startDate: new Date(2019, 4, 12),
    endDate: new Date(2019, 7, 30),
  },
  {
    startDate: new Date(2014, 3, 17),
    endDate: new Date(2015, 7, 15),
  },
];

export const mockGroupEpicsQueryResponse = {
  data: {
    group: {
      id: 'gid://gitlab/Group/2',
      name: 'Gitlab Org',
      epics: {
        edges: [
          {
            node: {
              id: 'gid://gitlab/Epic/40',
              title: 'Marketing epic',
              startDate: '2017-12-25',
              dueDate: '2018-03-09',
              webUrl: '/groups/gitlab-org/marketing/-/epics/1',
              group: {
                name: 'Gitlab Org',
                fullName: 'Gitlab Org',
              },
            },
          },
          {
            node: {
              id: 'gid://gitlab/Epic/41',
              title: 'Another marketing',
              startDate: '2017-12-26',
              dueDate: '2018-03-10',
              webUrl: '/groups/gitlab-org/marketing/-/epics/2',
              group: {
                name: 'Gitlab Org',
                fullName: 'Gitlab Org',
              },
            },
          },
        ],
      },
    },
  },
};

export const mockGroupEpicsQueryResponseFormatted = [
  {
    id: 'gid://gitlab/Epic/40',
    title: 'Marketing epic',
    startDate: '2017-12-25',
    dueDate: '2018-03-09',
    webUrl: '/groups/gitlab-org/marketing/-/epics/1',
    group: {
      name: 'Gitlab Org',
      fullName: 'Gitlab Org',
    },
    groupName: 'Gitlab Org',
    groupFullName: 'Gitlab Org',
  },
  {
    id: 'gid://gitlab/Epic/41',
    title: 'Another marketing',
    startDate: '2017-12-26',
    dueDate: '2018-03-10',
    webUrl: '/groups/gitlab-org/marketing/-/epics/2',
    group: {
      name: 'Gitlab Org',
      fullName: 'Gitlab Org',
    },
    groupName: 'Gitlab Org',
    groupFullName: 'Gitlab Org',
  },
];

export const mockEpicChildEpicsQueryResponse = {
  data: {
    group: {
      id: 'gid://gitlab/Group/2',
      name: 'Gitlab Org',
      epic: {
        id: 'gid://gitlab/Epic/1',
        title: 'Error omnis quos consequatur',
        children: {
          edges: mockGroupEpicsQueryResponse.data.group.epics.edges,
        },
      },
    },
  },
};

export const mockEpicChildEpicsQueryResponseFormatted = {
  data: {
    group: {
      id: 'gid://gitlab/Group/2',
      name: 'Gitlab Org',
      epic: {
        id: 'gid://gitlab/Epic/1',
        title: 'Error omnis quos consequatur',
        children: [mockFormattedChildEpic1, mockFormattedChildEpic2],
      },
    },
  },
};

export const rawMilestones = [
  {
    id: 'gid://gitlab/Milestone/40',
    iid: 1,
    state: 'active',
    description: null,
    title: 'Milestone 1',
    startDate: '2017-12-25',
    dueDate: '2018-03-09',
    webPath: '/groups/gitlab-org/-/milestones/1',
  },
  {
    id: 'gid://gitlab/Milestone/41',
    iid: 2,
    state: 'active',
    description: null,
    title: 'Milestone 2',
    startDate: '2017-12-26',
    dueDate: '2018-03-10',
    webPath: '/groups/gitlab-org/-/milestones/2',
  },
];

export const mockMilestone = {
  id: 1,
  iid: 1,
  state: 'active',
  description:
    'Explicabo et soluta minus praesentium minima ab et voluptatem. Quas architecto vero corrupti voluptatibus labore accusantium consectetur. Aliquam aut impedit voluptates illum molestias aut harum. Aut non odio praesentium aut.\n\nQuo asperiores aliquid sed nobis. Omnis sint iste provident numquam. Qui voluptatem tempore aut aut voluptas dolorem qui.\n\nEst est nemo quod est. Odit modi eos natus cum illo aut. Expedita nostrum ea est omnis magnam ut eveniet maxime. Itaque ipsam provident minima et occaecati ut. Dicta est perferendis sequi perspiciatis rerum voluptatum deserunt.',
  title:
    'Cupiditate exercitationem unde harum reprehenderit maxime eius velit recusandae incidunt quia.',
  groupId: 2,
  groupName: 'Gitlab Org',
  groupFullName: 'Gitlab Org',
  startDate: new Date('2017-07-10'),
  endDate: new Date('2018-06-02'),
  webPath: '/groups/gitlab-org/-/milestones/1',
};

export const mockMilestone2 = {
  id: 2,
  iid: 2,
  state: 'active',
  description:
    'Explicabo et soluta minus praesentium minima ab et voluptatem. Quas architecto vero corrupti voluptatibus labore accusantium consectetur. Aliquam aut impedit voluptates illum molestias aut harum. Aut non odio praesentium aut.\n\nQuo asperiores aliquid sed nobis. Omnis sint iste provident numquam. Qui voluptatem tempore aut aut voluptas dolorem qui.\n\nEst est nemo quod est. Odit modi eos natus cum illo aut. Expedita nostrum ea est omnis magnam ut eveniet maxime. Itaque ipsam provident minima et occaecati ut. Dicta est perferendis sequi perspiciatis rerum voluptatum deserunt.',
  title: 'Milestone 2',
  groupId: 2,
  groupName: 'Gitlab Org',
  groupFullName: 'Gitlab Org',
  startDate: new Date('2017-11-10'),
  endDate: new Date('2018-07-02'),
  webPath: '/groups/gitlab-org/-/milestones/1',
};

export const mockFormattedMilestone = {
  id: 1,
  iid: 1,
  state: 'active',
  title:
    'Cupiditate exercitationem unde harum reprehenderit maxime eius velit recusandae incidunt quia.',
  description:
    'Explicabo et soluta minus praesentium minima ab et voluptatem. Quas architecto vero corrupti voluptatibus labore accusantium consectetur. Aliquam aut impedit voluptates illum molestias aut harum. Aut non odio praesentium aut.\n\nQuo asperiores aliquid sed nobis. Omnis sint iste provident numquam. Qui voluptatem tempore aut aut voluptas dolorem qui.\n\nEst est nemo quod est. Odit modi eos natus cum illo aut. Expedita nostrum ea est omnis magnam ut eveniet maxime. Itaque ipsam provident minima et occaecati ut. Dicta est perferendis sequi perspiciatis rerum voluptatum deserunt.',
  groupId: 2,
  groupName: 'Gitlab Org',
  groupFullName: 'Gitlab Org',
  startDate: new Date(2017, 10, 1),
  originalStartDate: new Date(2017, 5, 26),
  endDate: new Date(2018, 2, 10),
  originalEndDate: new Date(2018, 2, 10),
  startDateOutOfRange: true,
  endDateOutOfRange: false,
  webPath: '/groups/gitlab-org/-/milestones/1',
  newMilestone: undefined,
};

export const mockGroupMilestonesQueryResponse = {
  data: {
    group: {
      id: 'gid://gitlab/Group/2',
      name: 'Gitlab Org',
      milestones: {
        edges: [
          {
            node: {
              iid: 1,
              id: 'gid://gitlab/Milestone/40',
              state: 'active',
              description: null,
              title: 'Milestone 1',
              startDate: '2017-12-25',
              dueDate: '2018-03-09',
              webPath: '/groups/gitlab-org/-/milestones/1',
            },
          },
          {
            node: {
              iid: 2,
              id: 'gid://gitlab/Milestone/41',
              state: 'active',
              description: null,
              title: 'Milestone 2',
              startDate: '2017-12-26',
              dueDate: '2018-03-10',
              webPath: '/groups/gitlab-org/-/milestones/2',
            },
          },
        ],
      },
    },
  },
};

export const mockEpicsWithParents = [
  {
    id: 'gid://gitlab-org/subgroup/Epic/1',
    hasParent: true,
    parent: {
      id: 'gid://gitlab-org/Epic/1',
    },
  },
  {
    id: 'gid://gitlab-org/subgroup/Epic/2',
    hasParent: true,
    parent: {
      id: 'gid://gitlab-org/subgroup/Epic/1',
    },
  },
  {
    id: 'gid://gitlab-org/subgroup/Epic/3',
    hasParent: true,
    parent: {
      id: 'gid://gitlab-org/subgroup/Epic/1',
    },
  },
  {
    id: 'gid://gitlab-org/subgroup/Epic/4',
    hasParent: true,
    parent: {
      id: 'gid://gitlab-org/subgroup/Epic/1',
    },
  },
];
