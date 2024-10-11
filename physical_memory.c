#include "physical_memory.h"
#include <stdbool.h>

// Page size (4KB)
#define PAGE_SIZE 4096

// Define usable memory region directly
#define USABLE_MEMORY_BASE 0x0000000000100000
#define USABLE_MEMORY_LIMIT 0x00000000BFEE0000

// Total number of pages in the system
// 0x00000000BFEE0000 - 0x0000000000100000 = (3218997248)decimal (BFDE0000)hex
// bytes in GB -> 2.9979248047 -> 3GB

#define NUM_PAGES ((USABLE_MEMORY_LIMIT - USABLE_MEMORY_BASE) / PAGE_SIZE)
// Bitmap to track physical memory usage (1 bit per page)
static uint8_t memory_bitmap[NUM_PAGES / 8];

// Utility macros for bitmap manipulation
// returns byte which corresponds to page
#define BITMAP_INDEX(page) (page / 8)
// returns bit within the byte which corresponds to page
#define BITMAP_OFFSET(page) (page % 8)
// Sets the bit corresponding to the given page to 1 using the OR (|) operator. This marks the page as used.
#define BITMAP_SET(page)                                                       \
  (memory_bitmap[BITMAP_INDEX(page)] |= (1 << BITMAP_OFFSET(page)))
// Clears the bit corresponding to the given page using the AND (&) operator with a negated mask. This marks the page as free.
#define BITMAP_CLEAR(page)                                                     \
  (memory_bitmap[BITMAP_INDEX(page)] &= ~(1 << BITMAP_OFFSET(page)))
// Tests whether a bit is set using the AND (&) operator. It checks if the page is currently used or free.
#define BITMAP_TEST(page)                                                      \
  (memory_bitmap[BITMAP_INDEX(page)] & (1 << BITMAP_OFFSET(page)))

static void mark_page_as_used(size_t page) { BITMAP_SET(page); }

static void mark_page_as_free(size_t page) { BITMAP_CLEAR(page); }

static bool is_page_free(size_t page) { return !BITMAP_TEST(page); }

/*
Iterates through the bitmap to find the first free page
*/
void *pmm_alloc_page() {
  for (size_t i = 0; i < NUM_PAGES; i++) {
    if (is_page_free(i)) {
      mark_page_as_used(i);
      return (void *)(USABLE_MEMORY_BASE +
                      i * PAGE_SIZE); // Return the physical address of the page
    }
  }

  // No free pages available
  return NULL;
}
/*
 * clears the bit associated with the physical page address
*/
void pmm_free_page(void *page) {
  size_t page_number = ((size_t)page - USABLE_MEMORY_BASE) / PAGE_SIZE;
  if (page_number >= NUM_PAGES) {
    return;
  }
  mark_page_as_free(page_number);
}

void pmm_init() {
  for (size_t page = 0; page < NUM_PAGES; page++) {
    mark_page_as_free(page);
  }
}
