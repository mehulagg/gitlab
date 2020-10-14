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
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatar_url:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
      web_url: 'http://192.168.1.209:3001/root',
    },
    {
      id: 3,
      name: 'Agustin Walker',
      username: 'lester.orn',
      state: 'active',
      avatar_url:
        'https://www.gravatar.com/avatar/772352aed294c4b3e6f236b0624764b6?s=80\u0026d=identicon',
      web_url: 'http://192.168.1.209:3001/lester.orn',
    },
    {
      id: 5,
      name: 'Joella Miller',
      username: 'era',
      state: 'active',
      avatar_url:
        'https://www.gravatar.com/avatar/8b306a0c173657865f6a5a6c7120b408?s=80\u0026d=identicon',
      web_url: 'http://192.168.1.209:3001/era',
    },
  ],
  headers: {
    [HEADER_TOTAL_ENTRIES]: '3',
    [HEADER_PAGE_NUMBER]: '1',
    [HEADER_ITEMS_PER_PAGE]: '1',
  },
};
