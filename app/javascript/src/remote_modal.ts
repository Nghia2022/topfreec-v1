import jQuery from 'jquery';
import { DatePicker } from './date_picker';
import { FormDependent } from './form_dependent';

const errorHTML = `
    <div class="modal-bg jsModalClose"></div>
    <div class="modal-content">
      <form>
        <div class="modal-panel">
          <a href="javascript:void(0)" class="modal-close-btn jsModalClose">
            <i class="feather icon-x"></i>
          </a>
          <div class="modal-ttl">
            エラー
          </div>
          <div class="modal-txt">
            <div class="form-content form-modal">
              <div class="form-txt s-txt-center">
                <span class="s-fc-01">予期せぬエラーが発生しました。再読み込みしてください。</span>
              </div>
            </div>
          </div>
          <div class="modal-footer s-flex-center">
            <button class="btn btn-theme-02 bs-normal" onclick="location.reload()">
              再読み込み
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
`;
const externalErrors = [413];

class RemoteModal {
  el: HTMLElement;
  trigger: any;
  onOpen?: (modal: RemoteModal, trigger: any) => void;
  declare winScrollTop;

  constructor(el, onOpen?) {
    this.el = el;
    this.onOpen = onOpen;
    this.setupEvents();
  }

  setupEvents() {
    jQuery(document.body)
      .on('click', '.jsModalOpen', async e => {
        e.preventDefault();

        this.trigger = e.target;
        this.trigger.disabled = true;

        const html = await this.get(this.trigger.href || this.trigger.dataset.href).catch(e => {
          console.error(e);
          return errorHTML;
        });
        jQuery(this.el).empty().append(html);
        this.setupFormFields();

        this.setupRemoteForm();
        this.open();

        this.onOpen && this.onOpen(this, this.trigger);
      })
      .on('click', '.jsModalClose', e => {
        e.preventDefault();

        this.close();
      });
  }

  clear() {
    jQuery(this.el)
      .unbind('ajax:success')
      .unbind('ajax:error');
    jQuery(this.el).empty();
    this.trigger.disabled = false;
  }

  async get(href) {
    return jQuery.get(href);
  }

  setupRemoteForm() {
    const $form = jQuery('form', this.el);
    $form.attr('data-remote', 'true');
    jQuery(this.el)
      .bind('ajax:beforeSend', (event) => this.onAjaxBeforeSend(event))
      .bind('ajax:success', (event) => this.onAjaxSuccess(event))
      .bind('ajax:error', (event) => this.onAjaxError(event));
  }

  setupFormFields() {
    new DatePicker();
    new FormDependent(this.el);
  }

  onAjaxBeforeSend(event) {
    externalErrors.forEach((status) => {
      jQuery(this.el).find(this.externalErrorClass(status)).addClass('s-d-hidden')
    });
  }

  onAjaxSuccess(event) {
    const xhr = event.detail[2];
    if (xhr.status === 201) {
      location.href = xhr.getResponseHeader('Location');
    } else {
      this.complete();
    }
    this.close();

    const flash = jQuery('#flash', event.detail[0]).data('flash');
    const displayLength = 6000;

    setTimeout(() => {
      this.complete();
    }, displayLength);
  }

  onAjaxError(event) {
    const xhr = event.detail[2];
    if (externalErrors.includes(xhr.status)) {
      jQuery(this.el).find(this.externalErrorClass(xhr.status)).removeClass('s-d-hidden')
      return;
    }

    const dom = event.detail[0];
    jQuery(this.el).find('.modal-panel').empty().append(jQuery('.modal-panel', dom).html());
    const $form = jQuery('form', this.el);
    $form.attr('data-remote', 'true');

    this.setupFormFields();
  }

  complete() {
    location.reload();
  }

  open() {
    this.winScrollTop = jQuery(window).scrollTop();

    jQuery(this.el).fadeIn();
    jQuery('.modal').css('height', jQuery(window).height());
    jQuery('.modal-bg').css('height', jQuery(window).height());
    jQuery('.modal-panel').css('height', jQuery(window).height());
    jQuery('body').addClass('modal-active');
  }

  close() {
    jQuery(this.el).fadeOut();
    jQuery('body,html').stop().animate({ scrollTop: this.winScrollTop }, 100);
    jQuery('body').removeClass('modal-active');

    setTimeout(() => this.clear(), 300);
  }

  externalErrorClass(status) {
    return `.error-${status}`;
  }
};

export { RemoteModal };
