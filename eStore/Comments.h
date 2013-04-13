//
//  Comments.h
//  eStore
//
//  Created by HNL on 4/4/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comments : NSObject

@property (nonatomic, strong) NSString *UserNickname; // name of UserNickname
@property (nonatomic, strong) NSArray *Photos; // Photos
@property (nonatomic, strong) NSArray *Videos; // Videos
@property (nonatomic, strong) NSString *UserLocation; // UserLocation
@property (nonatomic, strong) NSString *AuthorId; // AuthorId

@property (nonatomic, strong) NSString *ProductId; // ProductId
@property (nonatomic, strong) NSString *Title; // price
@property (nonatomic, strong) NSString *ReviewText; // price
@property (nonatomic, strong) NSString *ModerationStatus; // price
@property (nonatomic, strong) NSString *LastModeratedTime; // LastModeratedTime

@property (nonatomic, strong) NSString *Id; // Id
@property (nonatomic, strong) NSString *Rating; // Rating
@property (nonatomic, strong) NSString *ContentLocale; // ContentLocale
@property (nonatomic, strong) NSString *RatingRange; // RatingRange



@end
