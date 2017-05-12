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
        //         [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"IPFSDicomTriggerNotification" object:nil userInfo:@{@"hash": hash}];
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTriggered:) name:@"IPFSDicomTriggerNotification" object:nil];
    });
}

- (void)notificationTriggered:(NSNotification *)notification
{
    NSString *hash = notification.userInfo[@"hash"];

//    NSAlert *alert = [[NSAlert alloc] init];
//    alert.informativeText = hash;
//    alert.messageText = @"IPFS Hash";
//    [alert runModal];

    NSData *pdfData = [self pdfForHash:hash];

    NSError *error;
    NSString *globallyUniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *tempDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:globallyUniqueString];
    NSURL *tempDirectoryURL = [NSURL fileURLWithPath:tempDirectoryPath isDirectory:YES];

    if ([[NSFileManager defaultManager] createDirectoryAtURL:tempDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
        NSLog(@"Failed to create temp directory because: %@", error);
    }

    NSURL *newFileURL = [tempDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Report"]];
    if ([pdfData writeToURL:newFileURL options:NSDataWritingAtomic error:&error] == NO) {
        NSLog(@"Failed to write file to temp URL %@ because: %@", newFileURL,  error);
    }

    [[NSWorkspace sharedWorkspace] openURL:newFileURL];
}

- (NSData *)pdfForHash:(NSString *)hash
{
    NSImage *bogusPageImage = [[NSBundle bundleForClass:[self class]] imageForResource:@"bogus_page.pdf"];
    NSImage *bogusQRCode = [[NSBundle bundleForClass:[self class]] imageForResource:@"bogus_qr.png"];
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:10];
    NSFont *boldFont = [NSFont fontWithName:@"Helvetica Bold" size:10];
    NSDictionary *attr = @{NSFontAttributeName: font};
    NSDictionary *boldAttr = @{NSFontAttributeName: boldFont, NSUnderlineStyleAttributeName: @(YES)};


    NSMutableData *pdfData = [NSMutableData data];
    CGDataConsumerRef pdfDataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfData);
    CGRect mediaBox = CGRectMake(0, 0, 595, 842);

    CGContextRef pdfContext = CGPDFContextCreate(pdfDataConsumer, &mediaBox, (CFDictionaryRef)@{(NSString*)kCGPDFContextTitle:@"Report", (NSString*)kCGPDFContextCreator:@"IPFSDicom"});
    CGPDFContextBeginPage(pdfContext, (CFDictionaryRef)@{(NSString*)kCGPDFContextMediaBox:[NSData dataWithBytes:&mediaBox length:sizeof(CGRect)]});

    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:pdfContext flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:graphicsContext];

    // Start Quartz drawing
    // draw the logo
    [bogusPageImage drawInRect:mediaBox];

    NSSize bogusQRCodeSize = bogusQRCode.size;
    [bogusQRCode drawInRect:NSMakeRect(450, 150, 80, 80) fromRect:NSMakeRect(0, 0, bogusQRCodeSize.width, bogusQRCodeSize.height) operation:NSCompositingOperationCopy fraction:1];
    [@"IDENTIFIANT UNIQUE" drawAtPoint:NSMakePoint(178, 167) withAttributes:boldAttr];
//    [@"Identifiant unique" drawAtPoint:NSMakePoint(178, 127) withAttributes:boldAttr];
    [hash drawAtPoint:NSMakePoint(178, 137) withAttributes:attr];
    CGPDFContextEndPage(pdfContext);

    CGPDFContextClose(pdfContext);

    [graphicsContext flushGraphics];
    
    CFRelease(pdfDataConsumer);
    CFRelease(pdfContext);
    
    return pdfData;
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


