import { DatePicker } from './date_picker';

class SearchForm {
  constructor() {
    this.init()
  }

  init() {
    this.initMultipleSelect();
    this.initSingleSelect();
    this.initDatepicker();
    this.initMobile();
  }

  initMultipleSelect() {
    jQuery('select[multiple="multiple"]').each((_, el) => {
      const name = el.id;
      if (name == "") {
        return;
      }

      jQuery('#' + name).on('change', (e) => {
        const selected = jQuery(e.target).val();
        jQuery('input[type="checkbox"][name="' + name + '[]"]').val(selected);
      });

      jQuery('input[type="checkbox"][name="' + name + '[]"]').on('change', (e) => {
        const selected = jQuery('input[type="checkbox"][name="' + name + '[]"]:checked').map((_, el) => {
          return jQuery(el).val();
        }).get();
        jQuery(el).multipleSelect('setSelects', selected);
      });
    });
  }

  initSingleSelect() {
    jQuery('select[data-behavior="single-select"]').each((_, el) => {
      const id = el.id;
      jQuery('#' + id).on('change', (e) => {
        const val = jQuery(e.target).val();

        const ee = jQuery('input[name="' + el.name + '"][value="' + val + '"]');
        ee.prop('checked', true);
      });

      jQuery('input[type="radio"][name="' + el.name + '"]').on('change', (e) => {
        jQuery(el).multipleSelect('setSelects', [jQuery(e.target).val()]);
      });
    });
  }

  initDatepicker() {
    new DatePicker();
  }

  initMobile() {
    jQuery('[data-toggle="collapse"]').on('click', (e) => {
      this.toggleSearchTable();
    });
    this.hideSearchTable();
  }

  hideSearchTable() {
    jQuery('.jsSearchTableOpen').show();
    jQuery('.jsSearchTableClose').hide();
    jQuery('.jsSearchTable').hide();
  }

  toggleSearchTable() {
    jQuery('.jsSearchTableOpen').toggle();
    jQuery('.jsSearchTableClose').toggle();
    jQuery('.jsSearchTable').toggle();
  }
}

export { SearchForm };
