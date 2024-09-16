#include "physical_memory.h"
#include <stdbool.h>

// Maximum addressable memory based on the memory map
#define MAX_MEMORY 0xBFFE0000 // Up to 3 GB

// Total number of pages in the system
#define NUM_PAGES (MAX_MEMORY / PAGE_SIZE)
// Bitmap to track physical memory usage (1 bit per page)
static uint8_t memory_bitmap[NUM_PAGES / 8];

// Utility macros for bitmap manipulation
// returns byte which corresponds to page
#define BITMAP_INDEX(page) (page / 8)
// returns bit within the byte which corresponds to page
#define BITMAP_OFFSET(page) (page % 8)
// set the bit corresponding to that page to 1
#define BITMAP_SET(page)                                                       \
  (memory_bitmap[BITMAP_INDEX(page)] |= (1 << BITMAP_OFFSET(page)))
// clear bit
#define BITMAP_CLEAR(page)                                                     \
  (memory_bitmap[BITMAP_INDEX(page)] &= ~(1 << BITMAP_OFFSET(page)))
// test bit
#define BITMAP_TEST(page)                                                      \
  (memory_bitmap[BITMAP_INDEX(page)] & (1 << BITMAP_OFFSET(page)))
// memory map we got from calling int 0x15
memory_region_t memory_map[REGION_COUNT] = {
    {0x0000000000000000, 0x000000000009FC00, 0x1}, // Usable
    {0x000000000009FC00, 0x0000000000000400, 0x2}, // Reserved
    {0x00000000000F0000, 0x0000000000010000, 0x2}, // Reserved
    {0x0000000000100000, 0x00000000BFEE0000, 0x1}, // Usable
    {0x00000000BFFE0000, 0x0000000000020000, 0x2}, // Reserved
    {0x00000000FFFC0000, 0x0000000000040000, 0x2}, // Reserved
    {0x0000000100000000, 0x0000000040000000, 0x1} // Usable (above 4GB, ignored)
};

static void mark_page_as_used(size_t page) { BITMAP_SET(page); }

static void mark_page_as_free(size_t page) { BITMAP_CLEAR(page); }

static bool is_page_free(size_t page) { return !BITMAP_TEST(page); }

void pmm_init() {
  // Initialize all pages as used (reserved)
  for (size_t i = 0; i < NUM_PAGES; i++) {
    mark_page_as_used(i);
  }

  // Ensure page 0 is always marked as used
  mark_page_as_used(0);

  // Loop through the memory map and mark usable memory as free
  for (size_t i = 0; i < REGION_COUNT; i++) {
    memory_region_t region = memory_map[i];

    if (region.type == 0x1) { // Usable memory
      uint64_t region_base = region.base_addr;
      uint64_t region_length = region.length;
      uint64_t region_end = region_base + region_length;

      // Limit to 4GB (32-bit address space)
      if (region_base >= 0x100000000ULL) {
        continue; // Skip regions beyond 4GB
      }
      if (region_end > 0x100000000ULL) {
        region_end = 0x100000000ULL;
      }

      size_t start_page = (size_t)(region_base / PAGE_SIZE);
      size_t end_page = (size_t)(region_end / PAGE_SIZE);

      // Ensure start_page is at least 1 to avoid page 0
      if (start_page == 0) {
        start_page = 1;
      }

      // Ensure end_page does not exceed NUM_PAGES
      if (end_page > NUM_PAGES) {
        end_page = NUM_PAGES;
      }

      // Mark the pages in this region as free
      for (size_t page = start_page; page < end_page; page++) {
        mark_page_as_free(page);
      }
    }
  }
}
void *pmm_alloc_page() {
  for (size_t i = 0; i < NUM_PAGES; i++) {
    if (is_page_free(i)) {
      mark_page_as_used(i);
      return (void *)(i * PAGE_SIZE); // Return the physical address of the page
    }
  }

  // No free pages available
  return NULL;
}
void pmm_free_page(void *page) {
  size_t page_number = (size_t)page / PAGE_SIZE;
  if (page_number == 0) {
    return;
  }
  mark_page_as_free(page_number);
}
