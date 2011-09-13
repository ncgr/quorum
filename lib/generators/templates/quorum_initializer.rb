# Load Quorum Settings
QUORUM = YAML.load_file("#{::Rails.root.to_s}/config/quorum_settings.yml")[::Rails.env.to_s]

# gsub %{RAILS_ROOT}
QUORUM['blast'].each_value do |v| 
  unless v.nil? && v.kind_of?(Array)
    v.to_s.gsub!('%{RAILS_ROOT}', ::Rails.root.to_s)
  end
end

