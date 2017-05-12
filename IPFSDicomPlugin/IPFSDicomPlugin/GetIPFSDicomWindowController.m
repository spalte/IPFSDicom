//
//  GetIPFSDicomWindowController.m
//  IPFSDicomPlugin
//
//  Created by Joël Spaltenstein on 5/12/17.
//  Copyright © 2017 Spaltenstein Natural Image. All rights reserved.
//

#import "GetIPFSDicomWindowController.h"

@interface GetIPFSDicomWindowController ()
@property (weak) IBOutlet NSTextField* hashLabel;
@property (weak) IBOutlet NSProgressIndicator* progressIndicator;
@end

@implementation GetIPFSDicomWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)recoverFromIPFS:(id)sender
{
    NSString *hash = self.hashLabel.stringValue;
    [self.progressIndicator startAnimation:self];

    NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
    NSString *sharedSupportPath = [[pluginBundle sharedSupportURL] path];
    NSLog(@"Path = %@, hash = %@", sharedSupportPath, hash);

    NSTask *storeSCUTriggerTask = [[NSTask alloc] init];
    storeSCUTriggerTask.currentDirectoryPath = sharedSupportPath;
    storeSCUTriggerTask.launchPath = [sharedSupportPath stringByAppendingString:@"/studyStoreSCUTrigger.sh"];
    storeSCUTriggerTask.arguments = @[@"-hash", hash];
    storeSCUTriggerTask.terminationHandler = ^(NSTask *task) {[self.window close]; [self.progressIndicator stopAnimation:self];};

    [storeSCUTriggerTask launch];

//    [self.window close];
//    NSTask *task = [NSTask launchedTaskWithLaunchPath:[path stringByAppendingString:@" arguments:<#(nonnull NSArray<NSString *> *)#>]


}

@end
