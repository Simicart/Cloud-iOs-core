//
//  SCTheme01SlideShow.h
//
// Copyright 2013 Alexis Creuzot
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

typedef NS_ENUM(NSInteger, SCTheme01SlideShowTransitionType) {
    SCTheme01SlideShowTransitionFade,
    SCTheme01SlideShowTransitionSlide,
    SCTheme01SlideShowTransitionSlideUpDown
};

typedef NS_ENUM(NSInteger, SCTheme01SlideShowGestureType) {
    SCTheme01SlideShowGestureTap,
    SCTheme01SlideShowGestureSwipe,
    SCTheme01SlideShowGestureAll
};

@class MatrixSlideShow;
@protocol MatrixSlideShowDelegate <NSObject>
@optional
- (void) SCTheme01SlideShowDidNext:(MatrixSlideShow *) slideShow;
- (void) SCTheme01SlideShowDidPrevious:(MatrixSlideShow *) slideShow;
@end

@interface MatrixSlideShow : UIView

@property (nonatomic, unsafe_unretained) IBOutlet id <MatrixSlideShowDelegate> delegate;

@property  float delay;
@property  float transitionDuration;
@property  (readonly, nonatomic) NSUInteger currentIndex;
@property  (atomic) SCTheme01SlideShowTransitionType transitionType;
@property  (atomic) UIViewContentMode imagesContentMode;
@property  (strong,nonatomic) NSMutableArray * images;
@property (nonatomic) BOOL useImages;
@property (strong, nonatomic) NSMutableArray *imagePaths;
@property (nonatomic, strong) NSMutableArray *arrayImageView;

- (void) addImagesFromResources:(NSArray *) names;
- (void) emptyAndAddImagesFromResources:(NSArray *)names;
- (void) addGesture:(SCTheme01SlideShowGestureType)gestureType;
- (void) addImage:(UIImage *) image;
- (void) start;
- (void) stop;
- (void) previous;
- (void) next;

//Custom
- (void) addImagePath: (NSString *)imagePath;

@end

