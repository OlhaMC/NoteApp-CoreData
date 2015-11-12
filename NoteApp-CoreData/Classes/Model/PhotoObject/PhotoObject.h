//
//  PhotoObject.h
//  NoteApp-CoreData
//
//  Created by Admin on 10.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <CoreData/CoreData.h>
@class NoteObject;

@interface PhotoObject : NSManagedObject

@property (strong, nonatomic) NSData * photoData;
@property (strong, nonatomic) NSString * photoName;
@property (assign, nonatomic) NSUInteger photoNumber;
@property (strong, nonatomic) NSMutableSet * notesWithPhoto;

@end
