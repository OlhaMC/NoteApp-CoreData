//
//  NoteObject.h
//  NoteApp-CoreData
//
//  Created by Admin on 10.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <CoreData/CoreData.h>
@class PhotoObject;

@interface NoteObject : NSManagedObject

@property (strong, nonatomic) NSString * textDescription;
@property (strong, nonatomic) NSDate * timeStamp;
@property (strong, nonatomic) PhotoObject * photoForNote;

@end
