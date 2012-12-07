//
//  LoginViewController.m
//  Hours
//
//  Created by Tommy Wendelborg on 11/9/12.
//  Copyright (c) 2012 steria. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginState.h"

@interface LoginViewController ()
@property(nonatomic) bool isLoggedIn;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)logIn:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@end

@implementation LoginViewController
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize isLoggedIn = _isLoggedIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    bool isLoggedIn = [self checkStoredLogin];
    
    if(isLoggedIn)
    {
        [self performSegueWithIdentifier:@"LoggedInSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserName:nil];
    [self setPassword:nil];
    [self setErrorText:nil];
    [super viewDidUnload];
}
- (IBAction)logIn:(id)sender
{
    // TODO: Perform web login
    self.password.text = @"";
    self.isLoggedIn = YES;
}

-(bool) checkStoredLogin
{
    return NO;
}
@end
