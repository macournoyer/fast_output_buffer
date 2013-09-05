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
static VALUE cSafeConcatError;
static VALUE Iis_html_safe;
static VALUE Ito_s;


void BufferWrapper_free(void *data) {
  if (data) {
    BufferWrapper *wrapper = (BufferWrapper *) data;
    gh_buf_free(&wrapper->buf);
  }
}

// Try to get pointer and length to string in most efficient way possible.
static inline const char *getstring(VALUE obj, size_t *len) {
  int type = TYPE(obj);

  if (type == T_STRING) {
    *len = RSTRING_LEN(obj);
    return RSTRING_PTR(obj);
  } else if (type == T_DATA && rb_obj_class(obj) == cFastSafeBuffer) {
    BufferWrapper *wrapper = NULL;
    DATA_GET(obj, BufferWrapper, wrapper);
    *len = gh_buf_len(&wrapper->buf);
    return gh_buf_cstr(&wrapper->buf);
  } else {
    VALUE str = rb_funcall(obj, Ito_s, 0);
    *len = RSTRING_LEN(str);
    return RSTRING_PTR(str);
  }

  return NULL;
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

  size_t len = 0;
  const char *ptr = getstring(str, &len);

  if (!wrapper->html_safe || RTEST(rb_funcall(str, Iis_html_safe, 0))) {  
    // We don't care about escaping
    gh_buf_put(&wrapper->buf, ptr, len);
  } else {
    int escaped = houdini_escape_html(&wrapper->buf, (uint8_t *)ptr, len);
    // If not escaped Houdini does not concat.
    if (!escaped) gh_buf_put(&wrapper->buf, ptr, len);
  }

  return self;
}

VALUE FastSafeBuffer_safe_concat(VALUE self, VALUE str) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  // TODO ensure str is a String

  if (!wrapper->html_safe) rb_raise(cSafeConcatError, NULL);

  gh_buf_put(&wrapper->buf, RSTRING_PTR(str), RSTRING_LEN(str));

  return self;
}

VALUE FastSafeBuffer_to_str(VALUE self) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  return rb_str_new(gh_buf_cstr(&wrapper->buf), gh_buf_len(&wrapper->buf));
}

VALUE FastSafeBuffer_size(VALUE self) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  return INT2FIX(gh_buf_len(&wrapper->buf));
}

VALUE FastSafeBuffer_empty(VALUE self) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  return gh_buf_len(&wrapper->buf) == 0 ? Qtrue : Qfalse;
}

VALUE FastSafeBuffer_is_html_safe(VALUE self) {
  BufferWrapper *wrapper = NULL;
  DATA_GET(self, BufferWrapper, wrapper);
  return wrapper->html_safe ? Qtrue : Qfalse;
}

VALUE FastSafeBuffer_initialize_copy(VALUE self, VALUE other) {
  BufferWrapper *self_wrapper = NULL;
  BufferWrapper *other_wrapper = NULL;
  DATA_GET(self, BufferWrapper, self_wrapper);
  DATA_GET(other, BufferWrapper, other_wrapper);

  self_wrapper->html_safe = other_wrapper->html_safe;

  // FIXME Faster way to copy buffer?
  gh_buf_init(&self_wrapper->buf, gh_buf_len(&other_wrapper->buf));
  gh_buf_put(&self_wrapper->buf, gh_buf_cstr(&other_wrapper->buf), gh_buf_len(&other_wrapper->buf));

  return self;
}



////////// Ruby Init //////////

void Init_fast_output_buffer_ext() {
  cFastSafeBuffer = rb_define_class("FastSafeBuffer", rb_cObject);
  cSafeConcatError = rb_define_class_under(cFastSafeBuffer, "FastSafeBuffer", rb_cObject);

  Iis_html_safe = rb_intern("html_safe?");
  Ito_s = rb_intern("to_s");

  rb_define_alloc_func(cFastSafeBuffer, FastSafeBuffer_alloc);

  rb_define_method(cFastSafeBuffer, "concat", FastSafeBuffer_concat, 1);
  rb_define_method(cFastSafeBuffer, "<<", FastSafeBuffer_concat, 1);
  rb_define_method(cFastSafeBuffer, "append=", FastSafeBuffer_concat, 1);
  
  rb_define_method(cFastSafeBuffer, "safe_concat", FastSafeBuffer_safe_concat, 1);
  rb_define_method(cFastSafeBuffer, "safe_append=", FastSafeBuffer_safe_concat, 1);

  rb_define_method(cFastSafeBuffer, "to_str", FastSafeBuffer_to_str, 0);
  rb_define_method(cFastSafeBuffer, "size", FastSafeBuffer_size, 0);
  rb_define_method(cFastSafeBuffer, "length", FastSafeBuffer_size, 0);
  rb_define_method(cFastSafeBuffer, "empty?", FastSafeBuffer_empty, 0);

  rb_define_method(cFastSafeBuffer, "initialize_copy", FastSafeBuffer_initialize_copy, 1);

  rb_define_method(cFastSafeBuffer, "html_safe?", FastSafeBuffer_is_html_safe, 0);
}