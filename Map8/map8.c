#include "stdio.h"
#include "memory.h"
#include "stdlib.h"

typedef unsigned long   U32;
typedef unsigned short  U16;
typedef unsigned char   U8;


struct map8
{
  U16     to_u[256];
  U16*    to_8[256];
  U16     empty[256];
};

#define NOMAP  0xFFFF

typedef struct map8 Map8;

#define map_tou(m,c)   m->to_u[c]
#define map_to8(m,c)   m->to_8[c>>8][c&0xFF]


Map8*
new_map8(U16* map8, int callback())
{
  Map8* m;
  int i;

  m = (Map8*)malloc(sizeof(Map8));
  if (!m) abort();

  for (i = 0; i < 256; i++) {
    m->to_u[i] = map8[i];
    m->to_8[i] = 0;
    m->empty[i] = NOMAP;
  }

  /* create U16 -> UC_256 mapping */
  for (i = 0; i < 256; i++) {
    U16 u = m->to_u[i];
    U8 hi = u >> 8;
    U8 lo = u & 0xFF;
    /* printf("%d %d %d\n", u, hi, lo); */

    if (!m->to_8[hi]) {
      U16* map = (U16*)malloc(sizeof(U16)*256);
      int i;
      for (i = 0; i < 256; i++) {
	map[i] = NOMAP;
      }
      m->to_8[hi] = map;
    }
    m->to_8[hi][lo] = i;
  }

  /* fill empty spots */
  for (i = 0; i < 256; i++) {
    if (!m->to_8[i])
      m->to_8[i] = m->empty;
  }

  return m;
}


void
free_map8(Map8* m)
{
  int i;
  for (i = 0; i < 256; i++) {
    if (m->to_8[i] != m->empty)
      free(m->to_8[i]);
  }
  free(m);
}


main()
{
  
  Map8* m;
  int i;
  U16 x[256];
  for (i = 0; i < 256; i++) x[i]=i;

  m = new_map8(x, 0);

  printf("Hello %d %d\n", sizeof(Map8), sizeof(U16)*256);

  for (i = 0; i < 256; i++) {
    if (m->to_8[i] != m->empty) {
      printf("%d %p\n", i, m->to_8[i]);
    }
  }

  free_map8(m);

}
