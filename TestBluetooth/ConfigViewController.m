//
//  ConfigViewController.m
//  TestBluetooth
//
//  Created by LiPeng on 2/2/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import "ConfigViewController.h"
#import "SafeAreaManager.h"

@interface ConfigViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UIButton *confirmBtn;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation ConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configEditBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configEditBtn];
    [self.tableView reloadData];
}

- (void)configEditBtn
{
    if ([[SafeAreaManager shareInstance].safeAreasArray count]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeEditingState)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)changeEditingState
{
    if ([[SafeAreaManager shareInstance].safeAreasArray count] == 0) {
        [self setEditState:NO];
        return;
    }
    
    [self setEditState:!self.tableView.isEditing];
}

- (void)setEditState:(BOOL)flag
{
    [self.tableView setEditing:flag animated:YES];
    if (flag) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeEditingState)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeEditingState)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirm
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (_selectedIndexPath) {
        if (_selectedIndexPath.row == [[SafeAreaManager shareInstance].safeAreasArray count]) {
            
        } else {
            //    NSString* data = page1Data.text;
            UIViewController* view = segue.destinationViewController;
            if ([view respondsToSelector:@selector(setUserLocation:)]) {
                [view setValue:[SafeAreaManager shareInstance].safeAreasArray[_selectedIndexPath.row][@"location"] forKey:@"userLocation"];
            }
        }
    }
}

#pragma mark
#pragma mark tableview protocal delegate method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"报警设置";
    } else {
        return @"安全区域";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [[SafeAreaManager shareInstance].safeAreasArray count] + 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if ([cell viewWithTag:110] == nil) {
            UISwitch *senseSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 6, 51, 31)];
            senseSwitch.tag = 110;
            [cell addSubview:senseSwitch];
        }
        cell.textLabel.text = @"防误报";
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    } else {
        if (indexPath.row == [[SafeAreaManager shareInstance].safeAreasArray count]) {
            cell.textLabel.text = @"添加安全区域";
            cell.textLabel.textColor = [UIColor blueColor];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [SafeAreaManager shareInstance].safeAreasArray[indexPath.row][@"address"]];
            cell.textLabel.textColor = [UIColor brownColor];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        self.selectedIndexPath = indexPath;
        if (indexPath.row == [[SafeAreaManager shareInstance].safeAreasArray count]) {
            [self performSegueWithIdentifier:@"showCurPosMapViewControllerSegue" sender:self];
        } else {
            [self performSegueWithIdentifier:@"showSafeAreaMapViewControllerSegue" sender:self];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    } else {
        return !(indexPath.row == [[SafeAreaManager shareInstance].safeAreasArray count]);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [[SafeAreaManager shareInstance].safeAreasArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

@end
