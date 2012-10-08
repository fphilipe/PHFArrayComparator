#import "PHFAppDelegate.h"
#import "PHFRowsController.h"
#import "PHFSectionsController.h"
#import "PHFSectionsAndRowsController.h"

@implementation PHFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UITabBarController *tabBarController = [UITabBarController new];
    [tabBarController addChildViewController:[[UINavigationController alloc] initWithRootViewController:[PHFRowsController new]]];
    [tabBarController addChildViewController:[[UINavigationController alloc] initWithRootViewController:[PHFSectionsController new]]];
    [tabBarController addChildViewController:[[UINavigationController alloc] initWithRootViewController:[PHFSectionsAndRowsController new]]];
    [[self window] setRootViewController:tabBarController];
    [[self window] makeKeyAndVisible];

    return YES;
}

@synthesize window = _window;
- (UIWindow *)window {
    if (!_window)
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    return _window;
}

@end
