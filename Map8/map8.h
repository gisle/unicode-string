#ifdef PERL
#include "EXTERN.h"
#include "perl.h"
#else
typedef unsigned long   U32;
typedef unsigned short  U16;
typedef unsigned char   U8;
#endif

typedef U16 (*nochar_cb)(U16);

typedef struct map8
{
  U16     to_16[256];
  U16*    to_8 [256]; /* two level table */

  /* callback functions */
  nochar_cb  nomap8;
  nochar_cb  nomap16;
} Map8;

#define NOCHAR  0xFFFF
#define map8_to_char16(m,c)   m->to_16[c]
#define map8_to_char8(m,c)    m->to_8[c>>8][c&0xFF]

/* Prototypes */
Map8* map8_new(void);
Map8* map8_new_file(const char*);
void map8_addpair(Map8*, U8, U16);
void map8_nostrict(Map8*);
void map8_free(Map8*);

U16* map8_to_str16(Map8*, U8*, U16*, int, int*);
U8*  map8_to_str8 (Map8*, U16*, U8*, int, int*);

#ifdef DEBUGGING
#include <stdio.h>

void map8_print(Map8*);
void map8_fprint(Map8*,FILE*);
#endif
