#include "memory.h"

/*
Accepts three variable as parameters that copies the character (value)
to the first (size) characters of the memory pointed to, by the
argument str.
*/
void *memset(void *buffptr, int value, size_t size) {
  unsigned char *buf = (unsigned char *)buffptr;
  for (size_t i = 0; i < size; i++) {
    buf[i] = (unsigned char)value;
  }
  return buffptr;
}

/*
 copies a block of memory from a source (src_ptr) to a destination (dest_ptr)
 with (size) number of bytes to be copied
*/
void *memcpy(void *dest_ptr, const void *src_ptr, size_t size) {
  unsigned char *dst = (unsigned char *)dest_ptr;
  const unsigned char *src = (unsigned char *)src_ptr;
  for (size_t i = 0; i < size; i++) {
    dst[i] = src[i];
  }
  return dest_ptr;
}
