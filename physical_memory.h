#pragma once
#include <stddef.h>
#include <stdint.h>


void pmm_init();
void *pmm_alloc_page();
void pmm_free_page(void *page);
