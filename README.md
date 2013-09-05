# FastOutputBuffer

A faster output buffer for ActionView.

Rendering, rendering, rendering. That's all we're doing in our Rails apps! So why not make it as fast as possible?

The first time you render a view (template) in Rails, it will be compiled to a method. This is what a compiled view consisting of `<p><%= @title %></p>` look like.

    def _app_views_sites_index_html_erb___2525557208255998641_70225959709280(local_assigns, output_buffer)
      # ...
      @output_buffer = output_buffer || ActionView::OutputBuffer.new
      @output_buffer.safe_append='<p>'
      @output_buffer.append=( @title )
      @output_buffer.safe_append='</p>'
      # ...
    end

You see, all parts of your view are sent to a method of `ActionView::OutputBuffer`. `safe_append=` for chunks we know are safe and `append=` for stuff that is not and needs to be escaped. The more `<% ... %>` you have in your view, the more of those you'll have and the slower it will be.

If you have large views in your app, chances are most of the request time is spent rendering.

Don't worry, `FastOutputBuffer` is here to save your day!

## Installation

Add this line to your application's Gemfile:

    gem 'fast_output_buffer'

And then execute:

    $ bundle

That's it. `ActionView::OutputBuffer` will be replaced by FastOutputBuffer. Nothing to change in your code.

## Warning: UTF-8 only

FastOutputBuffer will not work with non-UTF-8. If you are dealing with other encodings do your best to transcode the string into a UTF-8 byte stream.

    utf8_string = non_utf8_string.encode('UTF-8')

## Benchmarks

Early artificial benchmarks indicate 20-30% increase in performance and several burned of wires.

    $ ruby -Ilib bench.rb
    ------------------------------------------------------------
    100 tags, 100 characters in tags, rendered 500 times

           user     system      total        real
    FastSafeBuffer             1.190000   0.010000   1.200000 (  1.209613)
    ActionView::OutputBuffer   1.470000   0.010000   1.480000 (  1.478364)
    ------------------------------------------------------------
    100 tags, 2500 characters in tags, rendered 500 times

           user     system      total        real
    FastSafeBuffer             1.910000   0.150000   2.060000 (  2.059526)
    ActionView::OutputBuffer   3.110000   0.100000   3.210000 (  3.210287)
    ------------------------------------------------------------
    500 tags, 2500 characters in tags, rendered 500 times

           user     system      total        real
    FastSafeBuffer             9.440000   0.780000  10.220000 ( 10.232674)
    ActionView::OutputBuffer  14.350000   0.650000  15.000000 ( 15.006372)
    ------------------------------------------------------------
    500 tags, 5000 characters in tags, rendered 500 times

           user     system      total        real
    FastSafeBuffer            14.060000   1.140000  15.200000 ( 15.193779)
    ActionView::OutputBuffer  19.630000   0.850000  20.480000 ( 20.489630)
    ------------------------------------------------------------
    1000 tags, 1000 characters in tags, rendered 500 times

           user     system      total        real
    FastSafeBuffer            13.550000   0.730000  14.280000 ( 14.287905)
    ActionView::OutputBuffer  17.310000   0.620000  17.930000 ( 17.932060)

## Thanks

Based on https://github.com/vmg/houdini <3
