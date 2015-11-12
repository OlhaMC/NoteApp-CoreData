//
//  ViewController.m
//  NoteApp-CoreData
//
//  Created by Admin on 08.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "NotesViewController.h"
#import "CoreDataController.h"
#import "NewNoteViewController.h"
#import "NoteViewCell.h"
#import "NoteObject.h"
#import "PhotoObject.h"

@interface NotesViewController ()

@property (strong, nonatomic) NSMutableArray * notesArray;

@end

@implementation NotesViewController

static NSString * const identifier = @"cell";

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
  // CoreDataController * coreDataManager = [CoreDataController sharedInstance];
   // NSLog(@"%@",[coreDataManager applicationDocumentsDirectory]);
}

- (void) viewWillAppear:(BOOL)animated
{
    [self reloadNotesArray];
    [self updatePhotoArray];
    [self verifyFirstNote];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Manage Notes array
- (void) reloadNotesArray
{
    CoreDataController * coreDataManager = [CoreDataController sharedInstance];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    [self.notesArray removeAllObjects];
    self.notesArray = [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self sortNotesByTime];
}

- (void) updatePhotoArray
{
    CoreDataController * coreDataManager = [CoreDataController sharedInstance];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    
    NSMutableArray * photoArray = [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
   for (PhotoObject * photo in photoArray)
    {
        if (photo.notesWithPhoto.count == 0)
        {
            [coreDataManager.managedObjectContext deleteObject:photo];
        }
    }
    
    NSError * error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't delete photo - %@ %@", error, [error localizedDescription]);
    }

   // NSLog(@"Photo array after relashions verification ------ %ld", photoArray.count);
}

- (void) verifyFirstNote
{
    if (!self.notesArray.count)
    {
        UILabel * initialLable =[[UILabel alloc] initWithFrame:
                                  CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        initialLable.text = @"No Note! Let's create one now. Touch + on the top right corner";
        initialLable.textColor = [UIColor blueColor];
        initialLable.textAlignment = NSTextAlignmentCenter;
        initialLable.numberOfLines = 0;
        self.tableView.backgroundView = initialLable;
    }
    else self.tableView.backgroundView = nil;
}

- (void) sortNotesByTime
{
    NSSortDescriptor * sortDescriptor;
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [self.notesArray sortedArrayUsingDescriptors:sortDescriptors];
    self.notesArray = [sortedArray mutableCopy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteViewCell * cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
    if (!cell)
    {
        cell = [[NoteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureNoteCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)configureNoteCell:(NoteViewCell*)cell atIndexPath: (NSIndexPath*)indexPath
{
    NoteObject * newNote = [self.notesArray objectAtIndex:indexPath.row];
    cell.noteTextView.text = newNote.textDescription;
    cell.noteTextView.textAlignment = NSTextAlignmentJustified;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"uk_UK"]];
    NSString * dateFormat = @"dd MMMM yyyy, HH:mm";
    [formatter setDateFormat:dateFormat];
    cell.dateLable.text = [formatter stringFromDate:newNote.timeStamp];
    cell.photoButton.tag = indexPath.row;
    cell.editButton.tag = indexPath.row;
    cell.deleteButton.tag = indexPath.row;
    
    cell.noteTextView.layer.borderWidth = 0.5f;
    cell.noteTextView.layer.borderColor = [[UIColor blueColor] CGColor];
    cell.noteTextView.layer.cornerRadius = 10.0f;
    [cell.noteTextView setTextContainerInset:UIEdgeInsetsMake(5, 5, 43, 5)];
    cell.noteTextView.scrollEnabled = NO;
    [cell.noteTextView sizeThatFits:cell.noteTextView.bounds.size];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
   return [self heightForConfiguredCellAtIndexPath:indexPath];
}

- (CGFloat)heightForConfiguredCellAtIndexPath: (NSIndexPath*)indexPath
{
    static NoteViewCell * sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    });
    [self configureNoteCell: sizingCell atIndexPath: indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell: (NoteViewCell*) sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - NoteCell buttons options

- (IBAction) editNoteAction: (UIButton*) sender
{
    NewNoteViewController * editNoteController = [self.storyboard instantiateViewControllerWithIdentifier:@"newNoteView"];
    editNoteController.title = @"Editing";
    
    NSIndexPath * currentPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NoteObject * currentNote = [self.notesArray objectAtIndex:currentPath.row];
    editNoteController.currentNote = currentNote;
    
    [self.navigationController pushViewController:editNoteController animated:YES];
}

- (IBAction)deleteNoteAction:(UIButton*)sender
{
    CoreDataController * coreDataManager = [CoreDataController sharedInstance];
    NSUInteger index = sender.tag;
    NoteObject * currentNote = [self.notesArray objectAtIndex:index];
    [coreDataManager.managedObjectContext deleteObject:currentNote];
    
    NSError * error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't delete - %@ %@", error, [error localizedDescription]);
    }
    else
    {
      dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Note deleted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
      });
    }
    [self reloadNotesArray];
    [self updatePhotoArray];
    [self.tableView reloadData];
}

- (IBAction)showPhotoAction: (UIButton*)sender
{
    NSUInteger index = sender.tag;
    NoteObject * currentNote = [self.notesArray objectAtIndex:index];
    PhotoObject * currentPhoto = currentNote.photoForNote;
    UIImage * photo = [UIImage imageWithData: currentPhoto.photoData];
    
    UIViewController * photoController = [[UIViewController alloc] init];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:photoController.view.bounds];
    imageView.image = photo;

    [photoController.view addSubview:imageView];
    
    [self.navigationController pushViewController:photoController animated:YES];
    
}

@end
