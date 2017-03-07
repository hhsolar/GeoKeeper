// Generated by Apple Swift version 3.0.2 (swiftlang-800.0.63 clang-800.0.42.1)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if defined(__has_attribute) && __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import Foundation;
@import CoreLocation;
@import CoreGraphics;
@import CoreData;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIWindow;
@class NSManagedObjectContext;
@class UIApplication;
@class NSPersistentContainer;

SWIFT_CLASS("_TtC9GeoKeeper11AppDelegate")
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow * _Nullable window;
@property (nonatomic, strong) NSManagedObjectContext * _Nonnull managedObjectContext;
@property (nonatomic, readonly, copy) NSURL * _Nonnull applicationDocumentsDirectory;
- (BOOL)application:(UIApplication * _Nonnull)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> * _Nullable)launchOptions;
- (void)applicationWillResignActive:(UIApplication * _Nonnull)application;
- (void)applicationDidEnterBackground:(UIApplication * _Nonnull)application;
- (void)applicationWillEnterForeground:(UIApplication * _Nonnull)application;
- (void)applicationDidBecomeActive:(UIApplication * _Nonnull)application;
- (void)applicationWillTerminate:(UIApplication * _Nonnull)application;
@property (nonatomic, strong) NSPersistentContainer * _Nonnull persistentContainer;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class UITableView;
@class UIStoryboardSegue;
@class UITableViewCell;
@class NSBundle;
@class NSCoder;

SWIFT_CLASS("_TtC9GeoKeeper28CategoryPickerViewController")
@interface CategoryPickerViewController : UITableViewController
@property (nonatomic, copy) NSString * _Nonnull selectedCategoryName;
@property (nonatomic, readonly, copy) NSArray<NSString *> * _Nonnull categories;
@property (nonatomic, copy) NSIndexPath * _Nonnull selectedIndexPath;
- (void)viewDidLoad;
- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section;
- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)tableView:(UITableView * _Nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (nonnull instancetype)initWithStyle:(UITableViewStyle)style OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class CLLocationManager;
@class CLLocation;
@class CLGeocoder;
@class CLPlacemark;
@class NSTimer;
@class UILabel;
@class UIButton;

SWIFT_CLASS("_TtC9GeoKeeper29CurrentLocationViewController")
@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, strong) NSManagedObjectContext * _Null_unspecified managedObjectContext;
@property (nonatomic, readonly, strong) CLLocationManager * _Nonnull locationManager;
@property (nonatomic, strong) CLLocation * _Nullable location;
@property (nonatomic) BOOL updatingLocation;
@property (nonatomic) NSError * _Nullable lastLocationError;
@property (nonatomic, readonly, strong) CLGeocoder * _Nonnull geocoder;
@property (nonatomic, strong) CLPlacemark * _Nullable placemark;
@property (nonatomic) BOOL performingReverseGeocoding;
@property (nonatomic) NSError * _Nullable lastGeocodingError;
@property (nonatomic, strong) NSTimer * _Nullable timer;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified messageLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified addressLabel;
@property (nonatomic, weak) IBOutlet UIButton * _Null_unspecified tagButton;
- (IBAction)getLocation;
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;
- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender;
- (void)locationManager:(CLLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nonnull)error;
- (void)locationManager:(CLLocationManager * _Nonnull)manager didUpdateLocations:(NSArray<CLLocation *> * _Nonnull)locations;
- (void)startLocationManager;
- (void)didTimeOut;
- (void)stopLocationManager;
- (void)updateLabels;
- (NSString * _Nonnull)stringFrom:(CLPlacemark * _Nonnull)placemark;
- (void)showLocationServicesDeniedAlert;
- (void)configureGetButton;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC9GeoKeeper7HudView")
@interface HudView : UIView
@property (nonatomic, copy) NSString * _Nonnull text;
+ (HudView * _Nonnull)hudInViewWithView:(UIView * _Nonnull)view animated:(BOOL)animated;
- (void)drawRect:(CGRect)rect;
- (void)showAnimatedWithAnimated:(BOOL)animated;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class NSEntityDescription;

SWIFT_CLASS("_TtC9GeoKeeper8Location")
@interface Location : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Location (SWIFT_EXTENSION(GeoKeeper))
@property (nonatomic) double lattitude;
@property (nonatomic) double longitude;
@property (nonatomic, copy) NSDate * _Nonnull date;
@property (nonatomic, copy) NSString * _Nonnull locationDescription;
@property (nonatomic, copy) NSString * _Nonnull category;
@property (nonatomic, strong) CLPlacemark * _Nullable placemark;
@end


SWIFT_CLASS("_TtC9GeoKeeper12LocationCell")
@interface LocationCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified addressLabel;
- (nonnull instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString * _Nullable)reuseIdentifier OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIGestureRecognizer;
@class UITextView;

SWIFT_CLASS("_TtC9GeoKeeper29LocationDetailsViewController")
@interface LocationDetailsViewController : UITableViewController
@property (nonatomic, weak) IBOutlet UITextView * _Null_unspecified descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified addressLabel;
@property (nonatomic, weak) IBOutlet UILabel * _Null_unspecified dateLabel;
@property (nonatomic, strong) NSManagedObjectContext * _Null_unspecified managedObjectContext;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark * _Nullable placemark;
@property (nonatomic, copy) NSString * _Nonnull categoryName;
@property (nonatomic, copy) NSDate * _Nonnull date;
- (void)viewDidLoad;
- (void)hideKeyboardWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer;
- (NSString * _Nonnull)formatDateWithDate:(NSDate * _Nonnull)date;
- (NSString * _Nonnull)stringFromPlacemarkWithPlacemark:(CLPlacemark * _Nonnull)placemark;
- (IBAction)done;
- (IBAction)cancel;
- (IBAction)categoryPickerDidPickCategoryWithSegue:(UIStoryboardSegue * _Nonnull)segue;
- (NSIndexPath * _Nullable)tableView:(UITableView * _Nonnull)tableView willSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)tableView:(UITableView * _Nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender;
- (nonnull instancetype)initWithStyle:(UITableViewStyle)style OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC9GeoKeeper23LocationsViewController")
@interface LocationsViewController : UITableViewController
@property (nonatomic, strong) NSManagedObjectContext * _Null_unspecified managedObjectContext;
@property (nonatomic, copy) NSArray<Location *> * _Nonnull locations;
- (void)viewDidLoad;
- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (nonnull instancetype)initWithStyle:(UITableViewStyle)style OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

#pragma clang diagnostic pop
