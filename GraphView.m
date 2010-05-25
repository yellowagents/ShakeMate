//
//  GraphView.m
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

#import "GraphView.h"


@implementation GraphView

- (void)updateHistoryWithX:(float)x y:(float)y z:(float)z {
  historyZ[nextIndex] = z / 3.0f;
  nextIndex = (nextIndex + 1) % kHistorySize;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  NSRect bounds = [self bounds];

  static const CGFloat lineW = 1.4;
  NSPoint pos;
  NSBezierPath *path = [NSBezierPath bezierPath];

  [[NSColor colorWithDeviceRed:0.9 green:0.95 blue:1.0 alpha:1.0] setFill];
  [[NSColor blackColor] setStroke];

  // start path offscreen
  [path moveToPoint:(NSPoint){bounds.size.width + lineW, bounds.size.height / 2}];

  for (unsigned int i = 0; i < kHistorySize; ++i) {
    float value = historyZ[(nextIndex + i) % kHistorySize];
    pos.x = bounds.size.width - (bounds.origin.x + (float)i / (float)(kHistorySize - 1) * bounds.size.width);
    pos.y = bounds.origin.y + bounds.size.height / 2 + value * bounds.size.height / 2;
    [path lineToPoint:pos];
  }

  // close path up
  pos.x = pos.x - lineW;
  [path lineToPoint:pos];
  [path lineToPoint:(NSPoint){-lineW, -lineW}];
  [path lineToPoint:(NSPoint){bounds.size.width + lineW, -lineW}];

  [path setLineWidth:lineW];
  [path fill];
  [path stroke];
}

@end
