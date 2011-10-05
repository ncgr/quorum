module Quorum
  module BlastsHelper

    #
    # Sortable column helper.
    #
    def kaminari_sort_by(path, title, col = nil)
      if (!path.respond_to? :to_sym) || (!title.kind_of? String)
        raise ArgumentError, "kaminari_sort_by expects path to be a " <<
          "Symbol and title to be a String."
      end

      # Set col
      col.nil? ? col = title.to_s.downcase.gsub(' ', '_') : col = col.to_s

      # Set the default direction param.
      params[:dir].nil? ? params[:dir] = "desc" : params[:dir]

      # Sort direction
      dir = (params[:dir].downcase == "desc") ? "asc" : "desc"

      if params[:dir] && col == params[:sort]
        up = image_tag("quorum/asc_arrow.png")
        down = image_tag("quorum/desc_arrow.png")
        title = (dir == "desc") ? title + up : title + down
      end

      # Sort options - :page must be passed along for pagination 
      # to work properly.
      options = {:sort => col, :dir => dir, :page => params[:page]}

      return link_to raw(title), self.send(path.to_sym, options)
    end

  end
end
