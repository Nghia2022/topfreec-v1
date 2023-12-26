import jQuery from 'jquery';
import { DatePicker } from './date_picker';
import { FormDependent } from './form_dependent';

class RemoteForm {
  constructor() {
    document.querySelectorAll('[data-behavior="remote-form"]').forEach((element) => {
      this.init(jQuery(element));
    });
  }

  async init($container) {
    const html = await jQuery.get($container.data('href')).catch(e => {
      console.error(e);
      return '<span class="s-fc-01">予期せぬエラーが発生しました</span>';
    });
    $container.empty().append(html);
    this.setupRemoteForm($container);
  }

  setupRemoteForm($container) {
    const $form = $container.find('form');
    $form.attr('data-remote', 'true');
    $container
      .bind('ajax:success', (event) => this.onAjaxSuccess(event))
      .bind('ajax:error', (event) => this.onAjaxError(event, $container));

    this.setupFormFields($container);
  }

  onAjaxSuccess(event) {
    const xhr = event.detail[2];
    if (xhr.status === 201) {
      location.href = xhr.getResponseHeader('Location');
    } else {
      this.complete();
    }
  }

  onAjaxError(event, $container) {
    const dom = event.detail[0];
    $container.empty().append(jQuery('body', dom).html());

    this.setupRemoteForm($container);
  }

  complete() {
    location.reload();
  }

  setupFormFields($container) {
    new DatePicker();
    new FormDependent($container);
  }
};

export { RemoteForm };
