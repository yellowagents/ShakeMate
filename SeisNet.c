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

#include <stdlib.h>
#include <arpa/inet.h>  /* for ntohs */

#include "SeisNet.h"

seis_net_t *seis_netInit(seis_net_t *d, seis_net_type_t type) {
  d->type = ntohs(type);
  switch (type) {
    case SEIS_NET_ACCELERATION:
      d->size = ntohs((uint16_t)sizeof(measurement_net_t));
      break;
    default:
      abort();
      break;
  }
  return d;
}

bool seis_netSend(int fd, seis_net_t *d) {
  return send(fd, d, htons(d->size), 0) > 0;
}
