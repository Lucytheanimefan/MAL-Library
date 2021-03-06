//
//  RatingTwentyConvert.h
//  MAL Library
//
//  Created by 小鳥遊六花 on 2/26/18.
//  Copyright © 2018 Atelier Shiori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RatingTwentyConvert : NSObject
+ (NSString *)convertRatingTwentyToActualScore:(int)twentyrating scoretype:(int)scoretype;
+ (int)translateKitsuTwentyScoreToMAL:(int)rating;
+ (int)translatestandardKitsuRatingtoRatingTwenty:(double)score;
+ (int)translateadvancedKitsuRatingtoRatingTwenty:(double)score;

@end
