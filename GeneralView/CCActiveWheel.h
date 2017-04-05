
#import <MBProgressHUD/MBProgressHUD.h>

@interface CCActiveWheel : MBProgressHUD


@property(nonatomic,copy) NSString* processString;
@property(nonatomic,copy) NSString* toastString;
@property(nonatomic,copy) NSString* warningString;

+ (CCActiveWheel*)showHUDAddedTo:(UIView *)view;
+ (CCActiveWheel*)showHUDAddedToWindow:(UIWindow *)window;

+ (void )showErrorHUDAddedTo:(UIView*) view errText:(NSString*)text;

+ (void)showWarningHUDAddedTo:(UIView *)view warningText:(NSString *)text;

+ (void)showPromptHUDAddedTo:(UIView*)view text:(NSString*)text;

+ (void)dismissForView:(UIView*)view;

+ (void)dismissForView:(UIView *)view delay:(NSTimeInterval)interval;

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView*)view warningText:(NSString*)text;
@end
