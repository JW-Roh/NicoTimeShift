//
//  NTSAppDelegate.h
//  NicoTimeShift
//
//  Created by deVbug on 2014. 5. 8..
//  Copyright (c) 2014년 deVbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GetComment.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, GetCommentDelegate> {
    IBOutlet NSTextField *field;
    IBOutlet NSMatrix *matrix;
    IBOutlet NSButton *button;
    IBOutlet NSProgressIndicator *indicator;
    IBOutlet NSTextField *label;
    GetComment *gc;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)go:(id)sender;
- (void)startIndicator;
- (void)stopIndicatorWithFail;

@end
