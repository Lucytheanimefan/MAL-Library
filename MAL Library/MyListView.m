//
//  MyListView.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/10/06.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "MyListView.h"
//#import "MyAnimeList.h"
#import "listservice.h"
#import "EditTitle.h"

@interface MyListView ()

@end

@implementation MyListView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
}

- (void)loadList:(int)list {
    [super loadList:list];
    [self setToolbarButtonState];
}

- (void)populateList:(id)object type:(int)type {
    [super populateList:object type:type];
    [self setToolbarButtonState];
}

- (void)filterStatusAsTabs:(NSButton *)btn{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.currentlist == 0) {
        if (self.watchingfilter != btn) {
            [defaults setValue:@(0) forKey:@"watchingfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"watchingfilter"];
        }
        if (self.completedfilter != btn) {
            [defaults setValue:@(0) forKey:@"completedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"completedfilter"];
        }
        if (self.droppedfilter != btn) {
            [defaults setValue:@(0) forKey:@"droppedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"droppedfilter"];
        }
        if (self.onholdfilter != btn) {
            [defaults setValue:@(0) forKey:@"onholdfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"onholdfilter"];
        }
        if (self.plantowatchfilter != btn) {
            [defaults setValue:@(0) forKey:@"plantowatchfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"plantowatchfilter"];
        }
    }
    else {
        if (self.readingfilter != btn) {
            [defaults setValue:@(0) forKey:@"readingfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"readingfilter"];
        }
        if (self.mangacompletedfilter != btn) {
            [defaults setValue:@(0) forKey:@"mcompletedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"mcompletedfilter"];
        }
        if (self.mangadroppedfilter != btn) {
            [defaults setValue:@(0) forKey:@"mdroppedfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"mdroppedfilter"];
        }
        if (self.mangaonholdfilter != btn) {
            [defaults setValue:@(0) forKey:@"monholdfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"monholdfilter"];
        }
        if (self.plantoreadfilter != btn) {
            [defaults setValue:@(0) forKey:@"plantoreadfilter"];
        }
        else {
            [defaults setValue:@(1) forKey:@"plantoreadfilter"];
        }
    }
}

- (IBAction)deletetitle:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init] ;
    NSDictionary *d;
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            d = self.animelistarraycontroller.selectedObjects[0];
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            d = self.mangalistarraycontroller.selectedObjects[0];
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    alert.messageText = [NSString stringWithFormat:@"Are you sure you want to delete %@ from your list?", d[@"title"]];
    alert.informativeText = @"Once you delete this title, this cannot be undone.";
    alert.alertStyle = NSAlertStyleWarning;
    [alert beginSheetModalForWindow:_mw.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSAlertFirstButtonReturn) {
            [self deletetitle];
        }
    }];
}

- (void)deletetitle {
    NSDictionary *d;
    NSNumber *selid;
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            d = self.animelistarraycontroller.selectedObjects[0];
            switch ([listservice getCurrentServiceID]) {
                case 1:
                    selid = d[@"id"];
                    break;
                case 2:
                    selid = d[@"entryid"];
                    break;
                default:
                    break;
            }
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            d = self.mangalistarraycontroller.selectedObjects[0];
            switch ([listservice getCurrentServiceID]) {
                case 1:
                    selid = d[@"id"];
                    break;
                case 2:
                    selid = d[@"entryid"];
                    break;
                default:
                    break;
            }
        }
        else {
            NSLog(@"Invalid Selection, aborting delete.");
            return;
        }
    }
    _deletetitleitem.enabled = NO;
    [listservice removeTitleFromList:selid.intValue withType:self.currentlist completion:^(id responseobject) {
        [_mw loadlist:@(true) type:self.currentlist];
    }error:^(NSError *error) {
        NSLog(@"%@",error);
        _deletetitleitem.enabled = YES;
    }];
}

- (IBAction)animelistdoubleclick:(id)sender {
    if (self.currentlist == 0) {
        if (self.animelisttb.selectedRow >=0) {
            if (self.animelisttb.selectedRow >-1) {
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = self.animelistarraycontroller.selectedObjects[0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]) {
                    NSNumber *idnum = d[@"id"];
                    [_mw loadinfo:idnum type:0 changeView:YES];
                }
                else if([action isEqualToString:@"Modify Title"]) {
                    [_mw.editviewcontroller showEditPopover:d showRelativeToRec:[self.animelisttb frameOfCellAtColumn:0 row:self.animelisttb.selectedRow] ofView:self.animelisttb preferredEdge:0 type:self.currentlist];
                }
            }
        }
    }
    else {
        if (self.mangalisttb.selectedRow >=0) {
            if (self.mangalisttb.selectedRow >-1) {
                NSString *action = [[NSUserDefaults standardUserDefaults] valueForKey: @"listdoubleclickaction"];
                NSDictionary *d = self.mangalistarraycontroller.selectedObjects[0];
                if ([action isEqualToString:@"View Info"]||[action isEqualToString:@"View Anime Info"]) {
                    NSNumber *idnum = d[@"id"];
                    [_mw loadinfo:idnum type:self.currentlist changeView:YES];
                }
                else if([action isEqualToString:@"Modify Title"]) {
                    [_mw.editviewcontroller showEditPopover:d showRelativeToRec:[self.mangalisttb frameOfCellAtColumn:0 row:self.mangalisttb.selectedRow] ofView:self.mangalisttb preferredEdge:0 type: self.currentlist];
                }
            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonState];
}

- (void)setToolbarButtonState{
    if (self.currentlist == 0) {
        if (self.animelistarraycontroller.selectedObjects.count > 0) {
            _edittitleitem.enabled = YES;
            _deletetitleitem.enabled = YES;
            _shareitem.enabled = YES;
            _titleinfoitem.enabled = YES;
        }
        else {
            _edittitleitem.enabled = NO;
            _deletetitleitem.enabled = NO;
            _shareitem.enabled = NO;
            _titleinfoitem.enabled = NO;
        }
    }
    else {
        if (self.mangalistarraycontroller.selectedObjects.count > 0) {
            _edittitleitem.enabled = YES;
            _deletetitleitem.enabled = YES;
            _shareitem.enabled = YES;
            _titleinfoitem.enabled = YES;
        }
        else {
            _edittitleitem.enabled = NO;
            _deletetitleitem.enabled = NO;
            _shareitem.enabled = NO;
            _titleinfoitem.enabled = NO;
        }
    }
}

@end
