#include "ruby.h"
#include "buffer.h"
#include "houdini.h"

#define RAISE_NOT_NULL(T) if(T == NULL) rb_raise(rb_eArgError, "NULL found for " # T " when shouldn't be.");
#define DATA_GET(from,type,name) Data_Get_Struct(from,type,name); RAISE_NOT_NULL(name);

typedef struct {
  gh_buf buf;
  int html_safe:1;
} BufferWrapper;

static VALUE cFastSafeBuffer;
static VALUE Iis_html_safe;


void BufferWrapper_free(void *data) {
  if (data) {
    BufferWrapper *wrapper = (BufferWrapper *) data;
    gh_buf_free(&wrapper->buf);
  }
}

VALUE FastSafeBuffer_alloc(VALUE klass) {
  BufferWrapper *wrapper = ALLOC_N(BufferWrapper, 1);
  gh_buf_init(&wrapper->buf, 102400);
  wrapper->html_safe = 1;

  return Data_Wrap_Struct(klass, NULL, BufferWrapper_free, wrapper);
}

VALUE FastSafeBuffer_concat(VALUE self, VALUE str) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  // TODO ensure str is a String

  if (!wrapper->html_safe || RTEST(rb_funcall(str, Iis_html_safe, 0))) {  
    // Unescaped
    gh_buf_put(&wrapper->buf, RSTRING_PTR(str), RSTRING_LEN(str));
  } else {
    // Escape before concatenating
    houdini_escape_html(&wrapper->buf, (uint8_t *)RSTRING_PTR(str), RSTRING_LEN(str));
  }

  return self;
}

VALUE FastSafeBuffer_to_str(VALUE self) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  return rb_str_new(gh_buf_cstr(&wrapper->buf), gh_buf_len(&wrapper->buf));
}

VALUE FastSafeBuffer_is_html_safe(VALUE self) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  return wrapper->html_safe ? Qtrue : Qfalse;
}



////////// Ruby Init //////////

void Init_fast_safe_buffer_ext() {
  cFastSafeBuffer = rb_define_class("FastSafeBuffer", rb_cObject);

  Iis_html_safe = rb_intern("html_safe?");

  rb_define_alloc_func(cFastSafeBuffer, FastSafeBuffer_alloc);

  rb_define_method(cFastSafeBuffer, "concat", FastSafeBuffer_concat, 1);
  rb_define_method(cFastSafeBuffer, "<<", FastSafeBuffer_concat, 1);

  rb_define_method(cFastSafeBuffer, "to_str", FastSafeBuffer_to_str, 0);

  rb_define_method(cFastSafeBuffer, "html_safe?", FastSafeBuffer_is_html_safe, 0);
}