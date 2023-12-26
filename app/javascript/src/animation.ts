import jQuery from 'jquery';

class Animation {
  constructor() {
    this.setup();
  }

  setup() {
    this.fadein();
    this.fadeup();
  }

  fadein() {
    jQuery('.js-fadeup').one('inview', function (event, isInView, visiblePartX, visiblePartY) {
      if (isInView) {
        jQuery(this).stop().addClass('js-fadeup-active');
      } else {
        jQuery(this).stop().removeClass('js-fadeup-active');
      }
    });
  }

  fadeup() {
    jQuery('.js-fadeup').one('inview', function (event, isInView, visiblePartX, visiblePartY) {
      if (isInView) {
        jQuery(this).stop().addClass('js-fadeup-active');
      } else {
        jQuery(this).stop().removeClass('js-fadeup-active');
      }
    });
  }
}
document.addEventListener('DOMContentLoaded', () => {
	jQuery('.js-fadein').one('inview', function (event, isInView, visiblePartX, visiblePartY) {
		if (isInView) {
			jQuery(this).stop().addClass('js-fadein-active');
		} else {
			jQuery(this).stop().removeClass('js-fadein-active');
		}
	});
});

export { Animation };
