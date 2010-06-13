//
//  MPActionsController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/19/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionsController.h"


@implementation MPActionsController

- (IBAction)openPreferences:(id)sender {
    [NSBundle loadNibNamed:@"Preferences" owner:self];
}

- (IBAction)installWithVariants:(id)sender {
	[self install:(id) nil];
}

- (IBAction)install:(id)sender {
	NSLog(@"Staring Installation");
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
		[self queueOperation:@"install" andPort:[port name]];
		NSLog(@"%@",[port name]);
        //[[MPActionLauncher sharedInstance]
        //    performSelectorInBackground:@selector(installPort:) withObject:port];
    }
	NSLog(@"Installation Completed");
}

- (IBAction)uninstall:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
 		[self queueOperation:@"uninstall" andPort:[port name]];
		NSLog(@"%@",[port name]);
		/*
       [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(uninstallPort:) withObject:port];
		 */
    }
}

- (IBAction)upgrade:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
		[self queueOperation:@"upgrade" andPort:[port name]];
		NSLog(@"%@",[port name]);
		/*
        [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(upgradePort:) withObject:port];
		 */
    }
}

- (IBAction)sync:(id)sender {
	[self queueOperation:@"sync" andPort:@"sync"];
	/*
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(sync) withObject:nil];
	 */
}

- (IBAction)selfupdate:(id)sender {
	[self queueOperation:@"selfupdate" andPort:@"selfupdate"];
	/*
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(selfupdate) withObject:nil];
	 */
}

- (IBAction)cancel:(id)sender {
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    BOOL enable = ![activityController busy];
    if ([[toolbarItem itemIdentifier] isEqual:[cancel itemIdentifier]]) {
        // Cancel button is enabled when busy
        return !enable;
    }
    
    return enable;
}

#pragma mark App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [tableController hidePredicateEditor:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pkgPath = [defaults objectForKey:@"PKGPath"];
    if (pkgPath == nil) {
        [self openPreferences:self];
    } else {
        [MPMacPorts setPKGPath:pkgPath];
        [[MPActionLauncher sharedInstance]
                    performSelectorInBackground:@selector(loadPorts) withObject:nil];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // I should check if it is running also 
    if (![[NSFileManager defaultManager] isWritableFileAtPath:[MPMacPorts PKGPath]]) {
        [[MPActionLauncher sharedInstance] cancelPortProcess];
    }
}

-(void) startQueue:(id) sender
{
	//[queue selectNext:nil];
	NSLog(@"Starting Queue");
	NSUInteger index;
	index = [queue selectionIndex];
	NSLog(@"Index before: %u", index);
	NSUInteger i;
	[queue setSelectionIndex: 0];
	for(i=0; i<=index; i++)
	{
		//We select each object from the array
		[queue setSelectionIndex:i];
		//We sleep the process for debugging puproses
		sleep(3);
		//We take the array of selected objects
		NSArray *wtf = [queue selectedObjects];
		//We then take the dictionary
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[wtf objectAtIndex:0]];
		//And we print the operations
		NSLog(@"Port %@ Operation %@",[dict objectForKey:@"port"], [dict objectForKey:@"operation"]);
		
	}
	[queue setSelectionIndex:index];
	//[queue remove:nil];

	
	//index = [queue selectionIndex];
	//NSLog(@"Index after: %u", index);
	//NSLog(@"Starting Queue Operations");
}

-(void) queueOperation:(NSString*)operation andPort:(NSString*)port
{
	NSLog(@"Queueing our Operation");
	//NSMutableDictionary *tempDict=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"wtf", @"operation", @"le_port", @"port", nil];
	[queue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:operation, @"operation", port, @"port",nil]];
	//[queue addObject: tempDict];
	//[queue retain];
	
}

@end
