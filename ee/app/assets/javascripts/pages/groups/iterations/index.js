import { initIterationsList } from 'ee/iterations';
import { Namespace } from 'ee/iterations/constants';

document.addEventListener('DOMContentLoaded', () => initIterationsList(Namespace.Group));
