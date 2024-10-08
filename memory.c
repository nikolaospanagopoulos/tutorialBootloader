#include "memory.h"

void *memset(void *buffptr, int value, size_t size){

	unsigned char *buf = (unsigned char *)buffptr;
	for(size_t i=0;i<size;i++){
		buf[i] = (unsigned char)value;
	}
	return buffptr;

}
