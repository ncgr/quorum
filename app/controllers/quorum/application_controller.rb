module Quorum
  class ApplicationController < ActionController::Base
    #
    # I18n flash helper. Set flash message based on key.
    #
    def set_flash_message(key, kind, options={})
      options[:scope] = "quorum.#{controller_name}"
      message = I18n.t("#{kind}", options)
      flash[key] = message if message.present?
    end
  end
end
