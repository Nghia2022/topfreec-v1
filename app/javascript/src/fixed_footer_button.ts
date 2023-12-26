import jQuery from "jquery";

class FixedFooterButton {
  constructor() {
    this.setup();
  }

  setup() {
    const fixedButton = jQuery(".jsFixedBtn");
    fixedButton.hide();

    jQuery(window).scroll(function () {
      if (jQuery(this).scrollTop() > 30) {
        fixedButton.fadeIn();
      } else {
        fixedButton.fadeOut();
      }
      const scrollHeight = jQuery(document).height();
      const scrollPosition =
        jQuery(window).height() + jQuery(window).scrollTop();
      const fixedHeight = jQuery(".jsFooter").innerHeight();
      if (scrollHeight - scrollPosition <= fixedHeight) {
        fixedButton.css({
          position: "absolute",
          bottom: fixedHeight,
        });
        jQuery("body").css({
          position: "relative",
        });
      } else {
        fixedButton.css({
          position: "fixed",
          bottom: 0,
        });
      }
    });
  }
}

export { FixedFooterButton };
