//
//  IPFSDicomPlugin.m
//  IPFSDicomPlugin
//
//  Created by Joël Spaltenstein on 5/12/17.
//  Copyright © 2017 Spaltenstein Natural Image. All rights reserved.
//

#import "IPFSDicomPlugin.h"
#import <objc/runtime.h>

#import "GetIPFSDicomWindowController.h"

static IPFSDicomPlugin *sharedIPFSDicomPlugin;

@interface IPFSDicomPlugin ()
@property (nonatomic, readwrite, strong) GetIPFSDicomWindowController *ipfsWindow;
@end


@implementation IPFSDicomPlugin

- (void)initPlugin
{
    sharedIPFSDicomPlugin = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
        NSMenu *networkMenu = [[mainMenu itemAtIndex:2] submenu];

        NSMenuItem *ipfsDicomMenuItem = [[NSMenuItem alloc] initWithTitle:@"Get From IPFS" action:@selector(getFromIPFS:) keyEquivalent:@""];

        [networkMenu insertItem:[NSMenuItem separatorItem] atIndex:0];
        [networkMenu insertItem:ipfsDicomMenuItem atIndex:0];

    });

    // add a method to the app for the menu item
    Method getFromIPFSMethod = class_getInstanceMethod([self class], @selector(getFromIPFS:));
    IMP getFromIPFSIMP = class_getMethodImplementation([self class], @selector(getFromIPFS:));
    const char* getFromIPFSTypes = method_getTypeEncoding(getFromIPFSMethod);
    class_addMethod([NSApp class], @selector(getFromIPFS:), getFromIPFSIMP, getFromIPFSTypes);



    NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
    NSString *sharedSupportPath = [[pluginBundle sharedSupportURL] path];

    NSString *homeDirPath = [[[NSFileManager defaultManager] homeDirectoryForCurrentUser] path];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[homeDirPath stringByAppendingString:@"/.ipfs"] isDirectory:NULL] == NO) {
        NSTask *ipfsInitTask = [[NSTask alloc] init];
        ipfsInitTask.currentDirectoryPath = sharedSupportPath;
        ipfsInitTask.launchPath = [sharedSupportPath stringByAppendingString:@"/ipfs"];
        ipfsInitTask.arguments = @[@"init"];
        [ipfsInitTask launch];
        [ipfsInitTask waitUntilExit];
    }

    // get the IPFS daemon up and running
    // check to see if IPFS is initialized, and initialize it if not
    NSTask *ipfsDeamonTask = [[NSTask alloc] init];
    ipfsDeamonTask.currentDirectoryPath = sharedSupportPath;
    ipfsDeamonTask.launchPath = [sharedSupportPath stringByAppendingString:@"/ipfs"];
    ipfsDeamonTask.arguments = @[@"daemon"];
    [ipfsDeamonTask launch];

    [[NSFileManager defaultManager] createDirectoryAtPath:[sharedSupportPath stringByAppendingString:@"/dicomStored"] withIntermediateDirectories:YES attributes:NULL error:NULL];
    NSTask *storeSCPTask = [[NSTask alloc] init];
    storeSCPTask.currentDirectoryPath = sharedSupportPath;
    storeSCPTask.launchPath = [sharedSupportPath stringByAppendingString:@"/launchStudyStoreSCP.sh"];
    [storeSCPTask launch];

    // bring the storeSCP up and running

}


- (IBAction)getFromIPFS:(id)sender
{
    if (sharedIPFSDicomPlugin.ipfsWindow == nil) {
        sharedIPFSDicomPlugin.ipfsWindow = [[GetIPFSDicomWindowController alloc] initWithWindowNibName:@"GetIPFSDicomWindowController"];
    }
    [sharedIPFSDicomPlugin.ipfsWindow.window makeKeyAndOrderFront:self];

    NSLog(@"getFromIPFS");
}

/** This function is called to apply your plugin */
- (long) filterImage: (NSString*) menuName;
{
    NSLog(@"IPFSDicomPlugin filterImage");
    return 1;
}

/** This function is the entry point of Pre-Process plugins */
- (long) processFiles: (NSMutableArray*) files;
{
    NSLog(@"IPFSDicomPlugin processFiles");
    return 1;
}

@end


