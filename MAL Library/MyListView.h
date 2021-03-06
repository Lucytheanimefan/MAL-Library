//
//  MyListView.h
//  MAL Library
//
//  Created by 桐間紗路 on 2017/10/06.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "ListView.h"
#import "MainWindow.h"

@interface MyListView : ListView
@property (strong) IBOutlet MainWindow *mw;

// Toolbar Items
@property (strong) IBOutlet NSToolbarItem *edittitleitem;
@property (strong) IBOutlet NSToolbarItem *deletetitleitem;
@property (strong) IBOutlet NSToolbarItem *shareitem;
@property (strong) IBOutlet NSToolbarItem *titleinfoitem;

- (IBAction)deletetitle:(id)sender;
@end
