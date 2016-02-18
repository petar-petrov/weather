//
//  MMMenuButtonViewController.m
//  weather
//
//  Created by Petar Petrov on 15/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMMenuButtonViewController.h"
#import <PKRevealController/PKRevealController.h>

@interface MMMenuButtonViewController ()

@end

@implementation MMMenuButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bullet_list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showNavigationMenu:)];
}

- (void)showNavigationMenu:(UIBarButtonItem *)sender {
        [self.revealController showViewController:self.revealController.leftViewController animated:YES completion:nil];
}

@end

@implementation MMMenuButtonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bullet_list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showNavigationMenu:)];
}

- (void)showNavigationMenu:(UIBarButtonItem *)sender {
    [self.revealController showViewController:self.revealController.leftViewController animated:YES completion:nil];
}

@end