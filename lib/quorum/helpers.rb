module Quorum
  module Helpers

    #
    # I18n flash helper. Set flash message based on key.
    #
    def set_flash_message(key, kind, options={})
      options[:scope] = "quorum.#{controller_name}"
      options[:scope] << ".errors" if key.to_s == "error"
      options[:scope] << ".notices" if key.to_s == "notice"
      options[:scope] << ".alerts" if key.to_s == "alert"
      message = I18n.t("#{kind}", options)
      flash[key] = message if message.present?
    end

  end
end
