/*
 *	$Id$ 
 *	Authors:
 * 	Randall H. Wood <rhwood@macports.org>
 *
 *	Copyright (c) 2007 Randall H. Wood <rhwood@macports.org>
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions
 *	are met:
 *	1.	Redistributions of source code must retain the above copyright
 *		notice, this list of conditions and the following disclaimer.
 *	2.	Redistributions in binary form must reproduce the above copyright
 *		notice, this list of conditions and the following disclaimer in the
 *		documentation and/or other materials provided with the distribution.
 *	3.	Neither the name of the copyright owner nor the names of contributors
 *		may be used to endorse or promote products derived from this software
 *		without specific prior written permission.
 * 
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 *	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *	POSSIBILITY OF SUCH DAMAGE.
 */




#include <tcl.h>

#include <Cocoa/Cocoa.h>

int Notifications_Send(int objc, Tcl_Obj *CONST objv[], int global, Tcl_Interp *interpreter) {
	/*/Debugging code starts here
	NSLog(@"Inside Notifications_Send!");
	if(*objv) {
		NSLog(@"size of STUFF is %d", objc);
	}
	//Debugging code ends here*/
	
	NSString *name = nil;
	NSMutableDictionary *info = nil;
	
	int tclCount;
	int tclResult;
	int i;
	const char **tclElements;
	
	
	/*/Debugging code starts here
	if(*objv) {
		NSLog(@"*objv pointer for name is NOT NULL");
	}
	//Debugging code ends here*/
	
	name = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
	++objv; --objc;
	
	/*/Debugging code starts here
	if(*objv) {
		NSLog(@"*objv pointer for Tcl_SplitList is NOT NULL, name is %@", name);
	}
	//Debugging code ends here*/
	
	tclResult = Tcl_SplitList(interpreter, Tcl_GetString(*objv), &tclCount, &tclElements);
	if (tclResult == TCL_OK) {
		
		/*/Debugging code starts here
		if(*objv) {
			NSLog(@"size of Dictionary is %d", tclCount);
		}
		for(i = 0; tclElements[i] != NULL; i++) {
			NSLog(@"Element in Dictionary is %@", [NSString stringWithUTF8String:tclElements[i]]);
		}
		for(i = 0; i < tclCount; i++) {
			NSLog(@"Element in Dictionary is %@", [NSString stringWithUTF8String:tclElements[i]]);
		}
		//Debugging code ends here*/
		
		
		//For now we return a single element dictionary containing the ui_* log message
		info = [NSMutableDictionary dictionaryWithCapacity:1];
		[info setObject:[NSString stringWithString:@"ui_msg"] forKey:[NSString stringWithUTF8String:Tcl_GetString(*objv)]];
		
		if (global != 0) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
		}
		
		
		
		/*
		info = [NSMutableDictionary dictionaryWithCapacity:(tclCount / 2)];
		for (i = 0; i < tclCount; i +=2) {
			[info setObject:[NSString stringWithUTF8String:tclElements[i + 1]] forKey:[NSString stringWithUTF8String:tclElements[i]]];
		}
		if (global != 0) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
		}*/
	} else {
		return TCL_ERROR;
	}
	
	return TCL_OK;
}

int Notifications_Command(ClientData clientData, Tcl_Interp *interpreter, int objc, Tcl_Obj *CONST objv[]) {
	//Debugging code starts here
	//NSLog(@"Inside Notifications_Command!");
	//Debugging code ends here
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSString *action = nil;
	int returnCode = TCL_ERROR;
	
	++objv, --objc;
	
	if (objc) {
		action = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
		++objv, --objc;
		if ([action isEqualToString:@"send"]) {
			
			/*/Debugging code starts here
			//if(*objv) {
				NSLog(@"*objv pointer in Notifications_Command is NOT NULL");
			}
			//Debugging code ends here*/
			
			if ([[NSString stringWithUTF8String:Tcl_GetString(*objv)] isEqualToString:@"global"]) {
				++objv, --objc;
				returnCode = Notifications_Send(objc, objv, 1, interpreter);				
			} else {
				returnCode = Notifications_Send(objc, objv, 0, interpreter);
			}
		}
	}
	
	[pool release];
	return returnCode;
}

int Notifications_Init(Tcl_Interp *interpreter) {
	
	if (Tcl_InitStubs(interpreter, "8.4", 0) == NULL) {
		return TCL_ERROR;
	}
	
	Tcl_CreateObjCommand(interpreter, "notifications", Notifications_Command, NULL, NULL);
	
	if (Tcl_PkgProvide(interpreter, "notifications", "1.0") != TCL_OK) {
		return TCL_ERROR;
	}
	
	return TCL_OK;
}

int Notifications_SafeInit(Tcl_Interp *interpreter) {
	
	return Notifications_Init(interpreter);
}