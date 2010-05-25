//
//  AppDelegate.m
//  ShakeMate
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

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window, graphView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // setup UDP socket
  udpSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  struct sockaddr_in sin;
  memset(&sin, 0, sizeof(sin));
  // listen on all interfaces
  sin.sin_addr.s_addr = INADDR_ANY;
  sin.sin_len = sizeof(struct sockaddr_in);
  sin.sin_family = AF_INET;
  sin.sin_port = htons(kSeismometerPort);

  bind(udpSocket, (const struct sockaddr*)&sin, sizeof(sin));

  // setup threaded notification support
  [self setUpThreadingSupport];

  // start listening to accelerometer notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(processNotification:)
                                               name:@"AccelerometerNotification"
                                             object:nil];

  // create a separate thread for receiving UDP packets
  networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoop:) object:nil];
  [networkThread start];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  return YES;
}

- (void)setUpThreadingSupport {
  if (notifications) return;

  notifications = [[NSMutableArray alloc] init];
  notificationLock = [[NSLock alloc] init];
  notificationThread = [[NSThread currentThread] retain];
  notificationPort = [[NSMachPort alloc] init];

  [notificationPort setDelegate:self];
  [[NSRunLoop currentRunLoop] addPort:notificationPort forMode:(NSString *)kCFRunLoopCommonModes];
}

- (void)processNotification:(NSNotification *)notification {
  if([NSThread currentThread] != notificationThread) {
    // Forward the notification to the correct thread, this is the socket thread

    NSDate* date = [[NSDate alloc] init];
    [notificationLock lock];
    [notifications addObject:notification];
    [notificationLock unlock];
    [notificationPort sendBeforeDate:date components:nil from:nil reserved:0];
    [date release];
  } else {
    // now we are in the main thread
    measurement_t meas;
    [(NSData *)[notification object] getBytes:&meas];
    [graphView updateHistoryWithX:meas.x y:meas.y z:meas.z];
  }
}

- (void)handleMachMessage:(void *)msg {
  [notificationLock lock];
  while ([notifications count]) {
    NSNotification *notification = [[notifications objectAtIndex:0] retain];
    [notifications removeObjectAtIndex:0];
    [notificationLock unlock];
    [self processNotification:notification];
    [notification release];
    [notificationLock lock];
  }
  [notificationLock unlock];
}

- (void)threadLoop:(id)object {
  measurement_net_t netmeas;
 
  while(!HELL_IS_FROZEN) {
    int count = recv(udpSocket, &netmeas, sizeof(netmeas), 0);
    if (count >= sizeof(measurement_net_t)) {
      // got something! pass it along
      measurement_t meas;
      
      if (seis_net_type(&netmeas) != SEIS_NET_ACCELERATION) {
        NSLog(@"Ignoring message %d", netmeas.type);
        continue;
      }
      
      measurement_netUnpack(&netmeas, &meas);
      NSString *msg = [[NSData alloc] initWithBytes:&meas length:sizeof(meas)];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"AccelerometerNotification" object:msg];
      [msg release];
		}
	}
}


@end
