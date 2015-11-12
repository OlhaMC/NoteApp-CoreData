//
//  NewNoteViewController.m
//  NoteApp-CoreData
//
//  Created by Admin on 09.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "NewNoteViewController.h"
#import "CoreDataController.h"
#import "NoteObject.h"
#import "PhotoObject.h"

@interface NewNoteViewController ()

@property (weak, nonatomic) IBOutlet UILabel *dateLable;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property (strong, nonatomic) CoreDataController * coreDataManager;

@end

@implementation NewNoteViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coreDataManager = [CoreDataController sharedInstance];
    
    self.noteTextView.layer.borderWidth = 1.0f;
    self.noteTextView.layer.borderColor = [[UIColor blueColor] CGColor];
    self.noteTextView.layer.cornerRadius = 10.0f;
    
    self.dateLable.text = [self stringFromCurrentDateAndTime];
    
    if (self.currentNote)
    {
        [self showNoteForEditing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Adjusting Note view
- (void) showNoteForEditing
{
    self.noteTextView.text = self.currentNote.textDescription;
}

- (NSString*) stringFromCurrentDateAndTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"uk_UK"]];
    NSString * dateFormat = @"dd MMMM yyyy, HH:mm";
    [formatter setDateFormat:dateFormat];
    return [formatter stringFromDate:[NSDate date]];
}

#pragma mark - Button actions
- (IBAction)saveAction:(id)sender
{
    if (self.noteTextView.text.length)
    {
        NoteObject * newNote;
        if (!self.currentNote)
        {
            newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.coreDataManager.managedObjectContext];
        }
        else newNote = self.currentNote;
        
        newNote.textDescription=self.noteTextView.text;
        newNote.timeStamp = [NSDate date];
        
        if (self.currentPhoto.photoData)
        {
            NSFetchRequest * fetchRequest = [[NSFetchRequest alloc]
                                             initWithEntityName:@"Photo"];
            
            NSMutableArray * photoArray = [[self.coreDataManager.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            for (PhotoObject * photo in photoArray)
            {
                if ([photo.photoName isEqualToString: self.currentPhoto.photoName])
                {
                    newNote.photoForNote = photo;
                    [photo.notesWithPhoto addObject: newNote];
                    break;
                }
            }
            
            if (!newNote.photoForNote)
            {
                newNote.photoForNote =self.currentPhoto;
                [self.currentPhoto.notesWithPhoto addObject: newNote];
            }
        }
        
        NSError * error = nil;
        if (![self.coreDataManager.managedObjectContext save:&error])
        {
            NSLog(@"Can't save note text - %@ %@", error, [error localizedDescription]);
        }
        else
        {
          dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Successfully saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
          });
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No text" message:@"Note is empty. Add some text." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    
}
- (IBAction)cancelAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhotoAction:(UIButton*)sender
{
    UIImagePickerController * piker = [[UIImagePickerController alloc] init];
    piker.delegate = self;
    piker.allowsEditing = YES;
    piker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:piker animated:YES completion:nil];
}

#pragma mark - ImagePickerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    PhotoObject * photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    photo.photoData = UIImagePNGRepresentation(pickedImage);
    photo.photoName =[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerReferenceURL]];
    self.currentPhoto = photo;

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
