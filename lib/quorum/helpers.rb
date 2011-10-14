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
    # Validate Model's sortable columns and direction.
    #
    def check_kaminari_sort(klass, column = nil, dir = nil)
      if (column.nil? && dir.nil?)
        return klass::DEFAULT_ORDER
      end
      begin
        unless klass::SORTABLE_COLUMNS.include? column
          raise ArgumentError, "Column (#{column.to_s}) is not sortable " <<
            "for model #{klass.to_s}. See #{klass.to_s}::SORTABLE_COLUMNS"
        end
      rescue ArgumentError => e
        Rails.logger.warn e.message
        return klass::DEFAULT_ORDER
      end
      safe_col = column
      safe_dir = (dir == "asc") ? "asc" : "desc"    
      return "%s %s" % [safe_col, safe_dir] # sql order by clause
    end
  
  end
end
