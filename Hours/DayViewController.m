//
//  DayViewController.m
//  Hours
//
//  Created by Tommy Wendelborg on 11/4/12.
//  Copyright (c) 2012 steria. All rights reserved.
//
#import "DayViewController.h"
#import "DataFactory.h"
#import "AppState.h"
#import "MBHudHelper.h"
#import "RegistrationAddViewController.h"
#import "RegistrationInfoViewController.h"

@interface DayViewController () <AppStateReceiver, MBProgressHUDDelegate>

// UI Controllers
@property (weak, nonatomic) IBOutlet UITableView *tblRegistrations;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonHeaderIcon;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDayName;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (strong, nonatomic) MBProgressHUD *hud;

// Data fetching
@property (strong, nonatomic) DataFactory *dataFactory;
@end

@implementation DayViewController

@synthesize state = _state;
@synthesize dataFactory = _dataFactory;
@synthesize hud = _hud;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupSwipe];
    
    self.dataFactory = [[DataFactory alloc] init];
}

-(void)setState:(AppState *)state
{
    _state = state;
    
    NSString *title;
    if(state)
    {
        title = [state currentDayTitle];
    }
    else
    {
        title = @"...";
    }
    self.buttonAdd.enabled = ![self.state isLocked];
    
    if([self.state isLocked])
    {
        self.buttonHeaderIcon.image = [UIImage imageNamed:@"lock.png"];
    }
    
    self.btnTitle.title = title;
    
    [self.tblRegistrations reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.buttonAdd.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    [self updateState];
}

-(void)updateState
{
    AppState *state = [AppState getOrLoadForReceiver:self]; // TODO: Move deserialization out of view controllers
    if(state)
    {
        self.state = state;
        
        if(self.state.registrationsToSave.count > 0)
        {
            // TODO: Send to server, refetch period afterwards!
        }
    }
    else
    {
        self.hud = [MBHudHelper ShowSpinnerForDelegate:self withView:self.tabBarController.view];
    }
}

- (void)didReceiveAppState:(AppState*) state
{
    NSLog(@"WARNING! for testing sake the current date is set to the first date of the loaded week");
    state.currentDate = [[state.currentWeek.days objectAtIndex:0] date];
    
    self.state = state;
    
    NSLog(@"Did receive data from the loader");
    [MBHudHelper HideSpinnerForHud:self.hud];
    self.hud = nil;
}

- (void) didFailLoadingAppStateWithError:(NSError *)error
{
    [MBHudHelper HideSpinnerForHud:self.hud];
    self.hud = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(self.state)
    {
        count = self.state.currentDay.registrations.count;
        if(!self.state.currentWeek.isSubmitted)
        {
            if(count == 0) // This triggers "copy yesterday"
            {
                count += 1;
            }
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(self.state)
    {
        if([self.state isLocked])
        {
            cell = [self getReadOnlyCell:tableView indexPath:indexPath];
        }
        else
        {
            cell = [self getEditableCell:tableView indexPath:indexPath];            
        }
    }
    else
    {
        cell = [self getCell:tableView forIndexPath:indexPath withCellIdentifier:@"EditDayCellStyle"];
        cell.textLabel.text = @"no data";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (UITableViewCell *)getEditableCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    Day *currentDay = self.state.currentDay;
    UITableViewCell *cell;
    
    if(indexPath.row >= currentDay.registrations.count)
            {
                cell = [self getCell:tableView forIndexPath:indexPath withCellIdentifier:@"CopyRegistrationsCell"];
                cell.textLabel.text = @"";
                cell.detailTextLabel.text = @"copy yesterday...";
            }
            else
            {
                cell = [self getCell:tableView forIndexPath:indexPath withCellIdentifier:@"ModifyDayCellStyle"];
                Registration *r = [currentDay.registrations objectAtIndex:indexPath.row];

                Project *p = [self.state getProjectByNumber:r.projectNumber andActivityCode:r.activityCode];
                cell.textLabel.text = p.projectName;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", r.hours];
            }
    return cell;
}

- (UITableViewCell *)getReadOnlyCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    Day *currentDay = self.state.currentDay;
    UITableViewCell *cell = [self getCell:tableView forIndexPath:indexPath withCellIdentifier:@"ViewDayCellStyle"];
    Registration *r = [currentDay.registrations objectAtIndex:indexPath.row];

    Project *p = [self.state getProjectByNumber:r.projectNumber andActivityCode:r.activityCode];
    cell.textLabel.text = p.projectName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", r.hours];

    return cell;
}

- (UITableViewCell *)getCell:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath withCellIdentifier:(NSString *)cellIdentifier {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ModifyRegistrationSegue"])
    {
        NSIndexPath *selectedRowIndex = [self.tblRegistrations indexPathForSelectedRow];
        RegistrationAddViewController *rvc = [segue destinationViewController];
        Registration *r = [[self.state.currentDay registrations] objectAtIndex:selectedRowIndex.row];

        [rvc setState:self.state andRegistration:r];
    }
    else if([[segue identifier] isEqualToString:@"AddRegistrationSegue"])
    {
        RegistrationAddViewController *rvc = [segue destinationViewController];
        [rvc setState:self.state andRegistration:nil];
    }
    else
    {
        NSIndexPath *selectedRowIndex = [self.tblRegistrations indexPathForSelectedRow];
        RegistrationInfoViewController *rvc = [segue destinationViewController];
        Registration *r = [[self.state.currentDay registrations] objectAtIndex:selectedRowIndex.row];
        
        [rvc setState:self.state andRegistration:r];
    }
}

- (void)setupSwipe
{
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(btnNext:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tblRegistrations addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(btnBack:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tblRegistrations addGestureRecognizer:oneFingerSwipeRight];
}

- (IBAction)btnNext:(id)sender
{
    self.state = [self.state navigateNextDay];
    
    if(!self.state.currentWeek)
    {
        [self updateState];
    }
}

- (IBAction)btnBack:(id)sender
{
    self.state = [self.state navigatePreviousDay];
    
    if(!self.state.currentWeek)
    {
        [self updateState];
    }
}

- (void)viewDidUnload {
    [self setTblRegistrations:nil];
    [self setBtnDayName:nil];
    [self setBtnTitle:nil];
    [self setButtonAdd:nil];
    [self setButtonHeaderIcon:nil];
    [self setHud:nil];
    [super viewDidUnload];
}

@end
