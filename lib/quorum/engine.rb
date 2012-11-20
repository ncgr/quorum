module Quorum
  class Engine < Rails::Engine
    isolate_namespace Quorum

    config.active_record.observers = "Quorum::JobQueueObserver"
  end
end
