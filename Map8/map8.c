/* $Id$
 *
 * Copyright 1998, Gisle Aas.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */

#include "map8.h"

#include <memory.h>
#include <stdlib.h>

static U16* nochar_map = 0;
static int  num_maps = 0;



Map8*
map8_new()
{
  Map8* m;
  int i;
  m = (Map8*)malloc(sizeof(Map8));
  if (!m) abort(); /* out of memory */

  if (!nochar_map) {
    /* initialize the shared array for second level u16 mapping */
    nochar_map = (U16*)malloc(sizeof(U16)*256);
    if (!nochar_map) abort();  /* out of memory */
    for (i = 0; i < 256; i++)
      nochar_map[i] = NOCHAR;
  }

  for (i = 0; i < 256; i++) {
    m->to_16[i] = NOCHAR;
    m->to_8[i]  = nochar_map;
  }

  m->def_to8  = NOCHAR;
  m->def_to16 = NOCHAR;
  m->cb_to8   = 0;
  m->cb_to16  = 0;

  num_maps++;
  return m;
}



void
map8_addpair(Map8* m, U8 u8, U16 u16)
{
  U8 hi = u16 >> 8;
  U8 lo = u16 & 0xFF;
  U16* himap = m->to_8[hi];
  if (himap == nochar_map) {
    int i;
    U16* map = (U16*)malloc(sizeof(U16)*256);
    if (!map) abort(); /* out of memory */
    for (i = 0; i < 256; i++) {
      map[i] = NOCHAR;
    }
    map[lo] = u8;
    m->to_8[hi] = map;
  } else if (himap[lo] == NOCHAR)
    himap[lo] = u8;
  if (m->to_16[u8] == NOCHAR)
    m->to_16[u8] = htons(u16);
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
map8_new_txtfile(const char *file)
{
  Map8* m;
  int count = 0;
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



Map8*
map8_new_binfile(const char *file)
{
  Map8* m;
  int count = 0;
  int n;
  int i;
  FILE* f;
  struct map8_filerec pair[256];

  f = fopen(file, "r");
  if (!f)
    return 0;

  if (fread(pair, sizeof(pair[0]), 1, f) != 1 ||
      pair[0].u8  != htons(MAP8_BINFILE_MAGIC_HI) ||
      pair[0].u16 != htons(MAP8_BINFILE_MAGIC_LO))
  {
    /* fprintf(stderr, "Bad magic\n"); */
    fclose(f);
    return 0;
  }
  
  m = map8_new();

  while ( (n = fread(pair, sizeof(pair[0]), sizeof(pair)/sizeof(pair[0]), f)))
  {
    for (i = 0; i < n; i++) {
      U16 u8  = ntohs(pair[i].u8);
      U16 u16 = ntohs(pair[i].u16);
      if (u8 > 255) continue;
      count++;
      map8_addpair(m, (U8)u8, u16);
    }
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
    if (m->to_8[i] != nochar_map)
      free(m->to_8[i]);
  }
  free(m);
  if (--num_maps == 0) {
    free(nochar_map);
    nochar_map = 0;
  }
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
      if (m->def_to16 != NOCHAR)
	*tmp16++ = m->def_to16;
      else if (m->cb_to16) {
	c = (m->cb_to16)(*str8);
	if (c != NOCHAR)
	  *tmp16++ = htons(c);
      }
    }
    str8++;
  }
  *tmp16 = 0x0000;  /* NUL16 terminate */
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
    U16 c = map8_to_char8(m, ntohs(*str16));
    if (c != NOCHAR && c <= 0xFF) {
      *tmp8++ = (U8)c;
    } else {
      if (m->def_to8 != NOCHAR)
	*tmp8++ = (U8)m->def_to8;
      else if (m->cb_to8) {
	c = (m->cb_to8)(ntohs(*str16));
	if (c != NOCHAR && c <= 0xFF)
	  *tmp8++ = (U8)c;
      }
    }
    str16++;
  }
  *tmp8 = '\0';  /* NUL terminate */
  if (rlen) {
    *rlen = tmp8 - str8;
  }
  return str8;
}


U8* map8_recode8(Map8* m1, Map8* m2, U8* from, U8* to, int len, int* rlen)
{
  U8* tmp;
  U16 uc;
  U16 u8;  /* need U16 to represent NOCHAR */

  if (from == 0)
    return 0;
  if (len < 0) {
    len = strlen(from);
  }
  if (to == 0) {
    to = (U8*)malloc(sizeof(U8)*(len+1));
    if (!to) abort();
  }

  tmp = to;
  while (len--) {
    /* First translate to common Unicode representation */
    U16 uc = map8_to_char16(m1, *from);
    if (uc == NOCHAR) {
      if (m1->def_to16 != NOCHAR)
	uc = m1->def_to16;
      else if (m1->cb_to16) {
	uc = (m1->cb_to16)(*from);
	if (uc == NOCHAR) {
	  from++;
	  continue;  /* no mapping exists for this char */
	}
	uc = htons(uc);
      } else {
	from++;
	continue;
      }
    }
    from++;

    /* Then map 'uc' back to the second 8-bit encoding */
    u8 = map8_to_char8(m2, ntohs(uc));
    if (u8 == NOCHAR || u8 > 0xFF) {
      if (m2->def_to8 != NOCHAR)
	u8 = m2->def_to8;
      else if (m2->cb_to8) {
	u8 = (m2->cb_to8)(ntohs(uc));
	if (u8 == NOCHAR || u8 > 0xFF)
	  continue;  /* no mapping exists for this char */
      } else
	continue;
    }

    *tmp++ = (U8)u8;
  }

  *tmp = '\0';  /* NUL terminate */
  if (rlen) {
    *rlen = tmp - to;
  }
  return to;
}


int map8_empty_block(Map8* m, U8 block)
{
  return m->to_8[block] == nochar_map;
}


#ifdef DEBUGGING

void
map8_print(Map8* m)
{
  map8_fprint(m, stdout);
}

void
map8_fprint(Map8* m, FILE* f)
{
  int i, j;
  long size = 0;
  int num_ident = 0;
  int num_nomap = 0;

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
      num_ident++;
    } else if (u == NOCHAR) {
      num_nomap++;
    } else {
      fprintf(f, "   %02x U+%04x  (%d --> %d)\n", i, u, i, u);
    }
  }
  if (num_ident)
    fprintf(f, "   +%d identity mappings\n", num_ident);
  if (num_nomap) {
    fprintf(f, "   +%d nochar mappings", num_nomap);
    if (m->nomap8)
      fprintf(f, " (mapping func %p)", m->nomap8);
    fprintf(f, "\n");
  }

  for (i = 0; i < 256; i++) {
    num_ident = 0;
    num_nomap = 0;
    if (m->to_8[i] == 0) {
      fprintf(f, " U16-U8: block %d NULL (should not happen)\n", i);
    } else if (m->to_8[i] != nochar_map) {
      size += sizeof(U16)*256;
      fprintf(f, " U16-U8:  block %d  %p\n", i, m->to_8[i]);
      for (j = 0; j < 256; j++) {
	int from = i*256+j;
	int to = m->to_8[i][j];
	if (from == to) {
	  num_ident++;
	} else if (to == NOCHAR) {
	  num_nomap++;
	  /* fprintf(f, "   NOMAP %d\n", from); */
	} else {
	  fprintf(f, "   U+%04x %02x  (%d --> %d)\n", from, to, from, to);
	}
      }
      if (num_ident)
	fprintf(f, "   +%d identity mappings\n", num_ident);
      if (num_nomap)
	fprintf(f, "   +%d nochar mappings\n", num_nomap);
    }
  }
  if (m->nomap16)
    fprintf(f, " U16-U8: nochar mapping func %p\n", m->nomap16);
  fprintf(f, " (%d bytes allocated)\n", size);
}
#endif
