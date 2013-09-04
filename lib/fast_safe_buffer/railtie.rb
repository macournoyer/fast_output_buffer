require "rails"

class FastSafeBuffer
  class Railtie < Rails::Railtie
    initializer "fast_safe_buffer.replace_output_buffer" do
      ActiveSupport.on_load(:action_view) do
        require "fast_safe_buffer/action_view"
      end
    end
  end
end