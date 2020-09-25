import { isString } from 'lodash';

export const datePropValidator = date => isString(date) || date === null;
