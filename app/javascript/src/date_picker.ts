import AirDatepicker from 'air-datepicker';
import localeJa from './air-datepicker/ja.js';

class DatePicker {
  constructor() {
    this.setupEvents();
  }

  setupEvents() {
    document.querySelectorAll('[data-behavior="datepicker"]').forEach((el: HTMLElement) => {
      const defaultOptions = {
        locale: localeJa,
      }
      const options = { ...defaultOptions, ...(JSON.parse(el.dataset['datepicker'] || '{}')) };
      new AirDatepicker(el, options);
    });
  }
}

export { DatePicker };
