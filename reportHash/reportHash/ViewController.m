//
//  ViewController.m
//  reportHash
//
//  Created by Joël Spaltenstein on 5/12/17.
//  Copyright © 2017 Spaltenstein Natural Image. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *arguments = [[NSProcessInfo processInfo] arguments];

//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.hashLabel.stringValue = arguments[2];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
