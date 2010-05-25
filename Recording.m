//
//  Recording.m
//  Seismometer
//  
//  Copyright (c) 2010 FFFF00 Agents AB
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "Recording.h"
#include <unistd.h>

static inline void bigEndianFloat(void *dest, float val) {
  uint32_t v = *((uint32_t *)&val);
  unsigned char *d = (unsigned char *)dest;

  d[0] = (v >> 24) & 0xff;
  d[1] = (v >> 16) & 0xff;
  d[2] = (v >> 8) & 0xff;
  d[3] = v & 0xff;
}

static inline void bigEndianDouble(void *dest, double val) {
  uint64_t v = *((uint64_t *)&val);
  unsigned char *d = (unsigned char *)dest;

  d[0] = (v >> 56) & 0xff;
  d[1] = (v >> 48) & 0xff;
  d[2] = (v >> 40) & 0xff;
  d[3] = (v >> 32) & 0xff;
  d[4] = (v >> 24) & 0xff;
  d[5] = (v >> 16) & 0xff;
  d[6] = (v >> 8) & 0xff;
  d[7] = v & 0xff;
}

measurement_net_t *measurement_netPack(measurement_t *source,
                                       measurement_net_t *dest) {
  /* NOTE We assume we're little endian here.
     THIS CODE IS NOT ARCHITECTUALLY PORTABLE. */
  bigEndianFloat(&dest->time, source->time);
  bigEndianDouble(&dest->x, source->x);
  bigEndianDouble(&dest->y, source->y);
  bigEndianDouble(&dest->z, source->z);
  return dest;
}

measurement_t *measurement_netUnpack(measurement_net_t *source,
                                     measurement_t *dest) {
  dest->shake = nan("empty");
  bigEndianFloat(&dest->time, source->time);
  bigEndianDouble(&dest->x, source->x);
  bigEndianDouble(&dest->y, source->y);
  bigEndianDouble(&dest->z, source->z);
  return dest;
}
