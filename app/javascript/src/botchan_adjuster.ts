import jQuery from 'jquery';

class BotchanAdjuster {
  constructor() {
    if (!document.querySelector('script[src*="botchan"]')) {
      return;
    }

    jQuery(window).on('scroll', () => {
      const $button = jQuery('.wc-static-ctn, .wc-webchat-ctn.wc-mobile[status="close"]');
      if (!$button.length) {
        return;
      }

      const documentHeight = jQuery(document).height();
      const scrollPosition = jQuery(window).height() + jQuery(window).scrollTop();
      const footerHeight = jQuery('footer').innerHeight();

      $button.css({ transition: 'none' });
      setTimeout(() => {
        $button
          .addClass('adjusted')
          .css({
            ...{ transition: '' },
            ...(
              documentHeight - scrollPosition <= footerHeight
                ? { position: 'absolute', bottom: footerHeight }
                : { position: 'fixed', bottom: 0 }
            )
          });
      }, 0);
    });
  }
}

export { BotchanAdjuster };
