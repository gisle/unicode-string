#include "map8.h"

#include <memory.h>
#include <stdlib.h>



Map8*
map8_new()
{
  Map8* m;
  int i;
  m = (Map8*)malloc(sizeof(Map8));
  if (!m) abort();

  for (i = 0; i < 256; i++) {
    m->to_16[i]  = NOCHAR;
    m->to_8[i]  = m->nomap;
    m->nomap[i] = NOCHAR;
  }
  m->nomap8 = 0;
  m->nomap16 = 0;
  return m;
}



void
map8_addpair(Map8* m, U8 u8, U16 u16)
{
  U8 hi = u16 >> 8;
  U8 lo = u16 & 0xFF;
  U16* himap = m->to_8[hi];
  if (himap == m->nomap) {
    int i;
    U16* map = (U16*)malloc(sizeof(U16)*256);
    if (!map) abort();
    for (i = 0; i < 256; i++) {
      map[i] = NOCHAR;
    }
    map[lo] = u8;
    m->to_8[hi] = map;
  } else if (himap[lo] == NOCHAR)
    himap[lo] = u8;
  if (m->to_16[u8] == NOCHAR)
    m->to_16[u8] = u16;
}



void
map8_nostrict(Map8* m)
{
  int i;
  if (!m) return;
  for (i = 0; i < 256; i++) {
    if (map8_to_char8(m, i) != NOCHAR)
      continue;
    if (map8_to_char16(m, i) != NOCHAR)
      continue;
    map8_addpair(m, i, i);
  }
}



Map8*
map8_new_file(const char *file)
{
  Map8* m;
  int count = 0;
  U16 map8[256];
  FILE* f;
  char buf[512];

  f = fopen(file, "r");
  if (!f)
    return 0;

  m = map8_new();

  while (fgets(buf, sizeof(buf), f)) {
    char *c1 = buf;
    char *c2;
    long from;
    long to;

    from = strtol(buf, &c1, 0);
    if (buf == c1 || from < 0 || from > 255)
      continue;  /* not a valid number */
    
    to = strtol(c1, &c2, 0);
    if (c1 == c2 || to < 0 || to > 0xFFFF)
      continue; /* not a valid second number */

    if (0 && from == to)
      continue;

    map8_addpair(m, from, to);
    count++;
  }
  fclose(f);

  if (!count) /* no mappings found */ {
    map8_free(m);
    return 0;
  }

  return m;
}



void
map8_free(Map8* m)
{
  int i;
  if (!m) return;
  for (i = 0; i < 256; i++) {
    if (m->to_8[i] != m->nomap)
      free(m->to_8[i]);
  }
  free(m);
}



U16* map8_to_str16(Map8* m, U8* str8, U16* str16, int len, int* rlen)
{
  U16* tmp16;
  if (str8 == 0)
    return 0;
  if (len < 0)
    len = strlen(str8);
  if (str16 == 0) {
    str16 = (U16*)malloc(sizeof(U16)*(len+1));
    if (!str16) abort();
  }
  tmp16 = str16;
  while (len--) {
    U16 c = map8_to_char16(m, *str8);
    if (c != NOCHAR) {
      *tmp16++ = c;
    } else {
      if (m->nomap8) {
	c = (m->nomap8)(*str8);
	if (c != NOCHAR)
	  *tmp16++ = c;
      }
      /* XXX do something here */
    }
    str8++;
  }
  *tmp16 = 0x0000;  /* NUL terminate */
  if (rlen) {
    *rlen = tmp16 - str16;
  }
  return str16;
}




U8* map8_to_str8(Map8* m, U16* str16, U8* str8, int len, int* rlen)
{
  U8* tmp8;
  if (str16 == 0)
    return 0;
  if (len < 0) {
    len = strlen(str8);
  }
  if (str8 == 0) {
    str8 = (U8*)malloc(sizeof(U8)*(len+1));
    if (!str8) abort();
  }
  tmp8 = str8;
  while (len--) {
    U16 c = map8_to_char8(m, *str16++);
    if (c != NOCHAR && c <= 0xFF) {
      *tmp8++ = (U8)c;
    } else {
      /* XXX do something here */
    }
  }
  *tmp8 = '\0';  /* NUL terminate */
  if (rlen) {
    *rlen = tmp8 - str8;
  }
  return str8;
}



#ifdef DEBUGGING

void
map8_print(Map8* m)
{
  map8_fprint(stdout, m);
}

void
map8_fprint(FILE* f, Map8* m)
{
  int i, j;
  long size = 0;
  int identity = 0;
  int nomap    = 0;

  if (!m) {
    fprintf(f, "NULL mapping\n");
    return;
  }
  size += sizeof(Map8);

  fprintf(f, "MAP8 %p\n", m);
  fprintf(f, " U8-U16\n");
  for (i = 0; i < 256; i++) {
    U16 u = m->to_16[i];
    if (i == u) {
      identity++;
    } else if (u == NOCHAR) {
      nomap++;
    } else {
      fprintf(f, "   %02x U+%04x  (%d --> %d)\n", i, u, i, u);
    }
  }
  if (identity)
    fprintf(f, "   +%d identity mappings\n", identity);
  if (nomap) {
    fprintf(f, "   +%d nochar mappings", nomap);
    if (m->nomap8)
      fprintf(f, " (mapping func %p)", m->nomap8);
    fprintf(f, "\n");
  }

  for (i = 0; i < 256; i++) {
    identity = 0;
    nomap    = 0;
    if (m->to_8[i] == 0) {
      fprintf(f, " U16-U8: block %d NULL (should not happen)\n", i);
    } else if (m->to_8[i] != m->nomap) {
      size += sizeof(U16)*256;
      fprintf(f, " U16-U8:  block %d  %p\n", i, m->to_8[i]);
      for (j = 0; j < 256; j++) {
	int from = i*256+j;
	int to = m->to_8[i][j];
	if (from == to) {
	  identity++;
	} else if (to == NOCHAR) {
	  nomap++;
	  /* fprintf(f, "   NOMAP %d\n", from); */
	} else {
	  fprintf(f, "   U+%04x %02x  (%d --> %d)\n", from, to, from, to);
	}
      }
      if (identity)
	fprintf(f, "   +%d identity mappings\n", identity);
      if (nomap)
	fprintf(f, "   +%d nochar mappings\n", nomap);
    }
  }
  if (m->nomap16)
    fprintf(f, " U16-U8: nochar mapping func %p\n", m->nomap16);
  fprintf(f, " (%d bytes allocated)\n", size);
}
#endif
