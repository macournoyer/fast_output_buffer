require "action_view"
require "action_view/buffers"
require "active_support/core_ext/kernel/reporting"

# Replace ActionView's slow implementation
silence_warnings do
  ActionView::OutputBuffer = FastSafeBuffer
end
