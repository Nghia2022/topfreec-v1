import jQuery from 'jquery';

class Top {
  constructor() {
    this.init();
  }

  init() {
    jQuery('.jsAccordion').hide();
    jQuery('.jsAccordionClose').hide();

    jQuery('.jsAccordionOpen,.jsAccordionClose').on('click', () => {
      jQuery('.jsAccordion,.jsAccordionOpen,.jsAccordionClose').toggle();
    });
  }
}

export { Top }
