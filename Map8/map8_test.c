
#include "map8.h"
#include <stdio.h>

main()
{
  U8*   str;
  U16*  ustr;
  Map8* map = map8_new_file("8859-1.txt");

  map8_nostrict(map);

  ustr = map8_to_str16(map, "\n\naas\n\n", 0, -1, 0);

  while (*ustr) {
    printf("U+%04X", *ustr);
    ustr++;
    if (*ustr)
      putchar(' ');
  }
  putchar('\n');

  map8_print(map);
  map8_free(map);

}



