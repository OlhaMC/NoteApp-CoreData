//
//  NewNoteViewController.h
//  NoteApp-CoreData
//
//  Created by Admin on 09.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteObject.h"
#import "PhotoObject.h"

@interface NewNoteViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NoteObject * currentNote;
@property (strong, nonatomic) PhotoObject * currentPhoto;

@end
