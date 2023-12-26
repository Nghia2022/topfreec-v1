import Rails from '@rails/ujs';
import jQuery from 'jquery';

import MediaLibraryWidget from '@/src/MediaLibraryWidget';

jQuery(() => {
  Rails.start();
});

jQuery(() => {
  const { cloudinaryCredentials = {} } = window as any;
  const { cloudName, apiKey } = cloudinaryCredentials;
  if (cloudName && apiKey) {
    new MediaLibraryWidget(cloudName, apiKey)
  }
});
