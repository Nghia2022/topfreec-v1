import jQuery from 'jquery';

declare var grecaptcha: any;

interface Window {
  onRecaptchaLoadCallback(): void;
  recaptchaCredentials: {
    site_key: string;
  };
}
declare var window: Window;

class Recaptcha {
  declare clientId;

  constructor() {
    this.init();
  }

  init() {
    jQuery(() => {
      const login_form = jQuery('#login_form');
      if (login_form.length < 1) {
        return;
      }

      const { recaptchaCredentials: { site_key } } = window;

      window.onRecaptchaLoadCallback = () => {
        this.clientId = grecaptcha.render('recaptcha_v3', {
          sitekey: site_key,
          size: 'invisible'
        });
      };

      login_form.submit((event) => {
        event.preventDefault();
        grecaptcha.ready(() => {
          this.executeRecaptcha();
        });
      });
    });
  }

  async executeRecaptcha() {
    const token = await grecaptcha.execute(this.clientId, { action: 'login' });
    jQuery('#g-recaptcha-response-data_login').val(token);
    jQuery('#login_form').unbind('submit').submit();
  }
}

export { Recaptcha };
