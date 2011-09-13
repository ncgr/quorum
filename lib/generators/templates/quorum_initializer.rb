# Load Quorum Settings
QUORUM = YAML.load_file("#{::Rails.root.to_s}/config/quorum_settings.yml")[::Rails.env.to_s]

# gsub %{RAILS_ROOT}
QUORUM['blast'].each_value { |v| v.gsub!('%{RAILS_ROOT}', ::Rails.root.to_s) }

