import jquery from 'jquery';
window.$ = window.jQuery = jquery

require("@rails/ujs").start();
require('jquery-inview');
require('multiple-select');

import { Animation } from '../src/animation';
import { SubNavigation } from '../src/sub_navigation';
import { Menu } from '../src/menu';
import { RemoteModal } from '../src/remote_modal';
import { RemoteForm } from '../src/remote_form';
import { DisplayToggler } from '../src/display_toggler';
import { Modal } from '../src/modal';
import { SearchForm } from '../src/search_form';
import { UploadFileName } from '../src/upload_file_name';
import { CloudinaryUploader } from '../src/cloudinary_uploader';
import { Carousel } from '../src/carousel';
import { Top } from '../src/top';
import { FixedFooterButton } from '../src/fixed_footer_button';
import { SearchTable } from '../src/search_table';
import { Recaptcha } from '../src/recaptcha';
import './devtools.ts';
import { TabChange } from '../src/service_flow';
import { BotchanAdjuster } from '../src/botchan_adjuster';
import { ToggleBtn } from '../src/toggle_btn';
import { ModalOpenTrigger } from '../src/modal_open_trigger';

document.addEventListener('DOMContentLoaded', () => {
  new Animation();
  new SubNavigation();
  new Menu();
  new RemoteModal(document.querySelector('.remote-modal-container'));
  new RemoteForm();
  new DisplayToggler();
  new Modal();
  new SearchForm();
  new UploadFileName();
  new CloudinaryUploader();
  new Carousel();
  new Top();
  new FixedFooterButton();
  new SearchTable();
  new Recaptcha();
  new TabChange();
  new BotchanAdjuster();
  new ToggleBtn();
  new ModalOpenTrigger();

  jQuery('select[multiple="multiple"]').multipleSelect({
    formatSelectAll: () => {
      return 'すべて';
    },
    formatAllSelected: () => {
      return '全て選択されています';
    },
    formatCountSelected: (count, total) => {
      return `${total} 件中 ${count} 件選択中`;
    }
  });
});
