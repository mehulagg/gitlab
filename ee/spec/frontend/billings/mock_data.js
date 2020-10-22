import {
  HEADER_TOTAL_ENTRIES,
  HEADER_PAGE_NUMBER,
  HEADER_ITEMS_PER_PAGE,
} from 'ee/billings/constants';

export const mockDataSubscription = {
  gold: {
    plan: {
      name: 'Gold',
      code: 'gold',
      trial: false,
      upgradable: false,
    },
    usage: {
      seats_in_subscription: 100,
      seats_in_use: 98,
      max_seats_used: 104,
      seats_owed: 4,
    },
    billing: {
      subscription_start_date: '2018-07-11',
      subscription_end_date: '2019-07-11',
      last_invoice: '2018-09-01',
      next_invoice: '2018-10-01',
    },
  },
  free: {
    plan: {
      name: null,
      code: null,
      trial: null,
      upgradable: null,
    },
    usage: {
      seats_in_subscription: 0,
      seats_in_use: 0,
      max_seats_used: 5,
      seats_owed: 0,
    },
    billing: {
      subscription_start_date: '2018-10-30',
      subscription_end_date: null,
      trial_ends_on: null,
    },
  },
  trial: {
    plan: {
      name: 'Gold',
      code: 'gold',
      trial: true,
      upgradable: false,
    },
    usage: {
      seats_in_subscription: 100,
      seats_in_use: 1,
      max_seats_used: 0,
      seats_owed: 0,
    },
    billing: {
      subscription_start_date: '2018-12-13',
      subscription_end_date: '2019-12-13',
      trial_ends_on: '2019-12-13',
    },
  },
};

export const mockDataSeats = {
  data: [
    {
      name: 'Administrator',
      username: 'root',
      avatar_url: 'path/to/img',
      web_url: 'path/to/user',
    },
    {
      name: 'Agustin Walker',
      username: 'lester.orn',
      avatar_url: 'path/to/img',
      web_url: 'path/to/user',
    },
    {
      name: 'Joella Miller',
      username: 'era',
      avatar_url: 'path/to/img',
      web_url: 'path/to/user',
    },
  ],
  headers: {
    [HEADER_TOTAL_ENTRIES]: '3',
    [HEADER_PAGE_NUMBER]: '1',
    [HEADER_ITEMS_PER_PAGE]: '1',
  },
};

export const seatsTableItems = [
  {
    user: {
      name: 'Administrator',
      username: '@root',
      avatar_url: 'path/to/img',
      web_url: 'path/to/user',
    },
  },
  {
    user: {
      name: 'Agustin Walker',
      username: '@lester.orn',
      avatar_url: 'path/to/img',
      web_url: 'path/to/user',
    },
  },
  {
    user: {
      name: 'Joella Miller',
      username: '@era',
      avatar_url: 'path/to/img',
      web_url: 'path/to/user',
    },
  },
];
