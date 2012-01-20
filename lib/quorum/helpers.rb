module Quorum
  module Helpers

    #
    # I18n flash helper. Set flash message based on key.
    #
    def set_flash_message(key, kind, options = {})
      options[:scope] = "quorum.#{controller_name}"
      options[:scope] << ".errors" if key.to_s == "error"
      options[:scope] << ".notices" if key.to_s == "notice"
      options[:scope] << ".alerts" if key.to_s == "alert"
      message = I18n.t("#{kind}", options)
      flash[key] = message if message.present?
    end

    #
    # Colorize console text.
    #
    module Colors
      ## Thanks to the Rspec team for this code! ##

      #
      # Main color method.
      #
      def color(text, color_code)
        "#{color_code}#{text}\e[0m"
      end

      #
      # Bold
      #
      def bold(text)
        color(text, "\e[1m")
      end

      #
      # White
      #
      def white(text)
        color(text, "\e[37m")
      end

      #
      # Green
      #
      def green(text)
        color(text, "\e[32m")
      end

      #
      # Red
      #
      def red(text)
        color(text, "\e[31m")
      end

      #
      # Magenta
      #
      def magenta(text)
        color(text, "\e[35m")
      end

      #
      # Yellow
      #
      def yellow(text)
        color(text, "\e[33m")
      end

      #
      # Blue
      #
      def blue(text)
        color(text, "\e[34m")
      end

      #
      # Grey
      #
      def grey(text)
        color(text, "\e[90m")
      end
    end

  end
end
