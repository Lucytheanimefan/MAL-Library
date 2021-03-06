//
//  InfoView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017-2018 Atelier Shiori Software and Moy IT Solutions. All rights reserved. Licensed under 3-clause BSD License
//

#import "InfoView.h"
#import "MainWindow.h"
#import "Utility.h"
#import "NSString+HTMLtoNSAttributedString.h"
#import "ReviewView.h"
#import "RecommendedTitleView.h"
#import "StreamPopup.h"
#import "listservice.h"

@interface InfoView ()
@property (strong) IBOutlet NSTextField *infoviewtitle;
@property (strong) IBOutlet NSTextField *infoviewalttitles;
@property (strong) IBOutlet NSImageView *infoviewposterimage;
@property (strong) IBOutlet RecommendedTitleView *otherpopoverviewcontroller;
@property (strong) IBOutlet NSButton *recommendedtitlebutton;
@property (strong) IBOutlet NSButton *sourcematerialbutton;
@property (strong) IBOutlet StreamPopup *steampopupviewcontroller;
@property (strong) IBOutlet NSPopover *streampopover;
@property (strong) IBOutlet NSButton *streambutton;
@property bool buttonmoved;
@end

@implementation InfoView

- (instancetype)init
{
    return [super initWithNibName:@"InfoView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    if (!_steampopupviewcontroller.isViewLoaded) {
        [_steampopupviewcontroller loadView];
    }
}

- (void)populateAnimeInfoView:(id)object{
    NSDictionary *d = object;
    NSMutableString *titles = [NSMutableString new];
    NSMutableString *details = [NSMutableString new];
    NSMutableString *genres = [NSMutableString new];
    NSAttributedString *background;
    _infoviewtitle.stringValue = d[@"title"];
    NSDictionary *dtitles =  d[@"other_titles"];
    NSMutableArray *othertitles = [NSMutableArray new];
    if (dtitles[@"english"] != nil){
        NSArray *e = dtitles[@"english"];
        for (NSString *etitle in e){
            [othertitles addObject:etitle];
        }
    }
    if (dtitles[@"japanese"] != nil){
        NSArray *j = dtitles[@"japanese"];
        for (NSString *jtitle in j){
            [othertitles addObject:jtitle];
        }
    }
    if (dtitles[@"synonyms"] != nil){
        NSArray *syn = dtitles[@"synonyms"];
        for (NSString *stitle in syn){
            [othertitles addObject:stitle];
        }
    }
    // Stream Check
    if (![_steampopupviewcontroller checkifdataexists:_infoviewtitle.stringValue]){
        bool found = false;
        for (NSString *t in othertitles) {
            if ((found = [_steampopupviewcontroller checkifdataexists:t])){
                _streambutton.hidden = false;
                break;
            }
        }
        if (!found) {
            _streambutton.hidden = true;
        }
    }
    else {
        _streambutton.hidden = false;
    }
    [titles appendString:[Utility appendstringwithArray:othertitles]];
    _infoviewalttitles.stringValue = titles;
    if (d[@"genres"]!= nil) {
        NSArray *genresa = d[@"genres"];
        [genres appendString:[Utility appendstringwithArray:genresa]];
    }
    else{
        [genres appendString:@"None"];
    }
    NSString *producers = nil;
    if (((NSArray *)d[@"producers"]).count > 0){
        producers = [Utility appendstringwithArray:(NSArray *)d[@"producers"]];
    }
    NSMutableString *openingthemes = nil;
    if (((NSArray *)d[@"opening_theme"]).count > 0) {
        openingthemes = [NSMutableString new];
        [openingthemes appendString:@"\nOpening Themes:\n"];
        for (NSString *theme in (NSArray *)d[@"opening_theme"]){
            [openingthemes appendFormat:@"%@\n",theme];
        }
    }
    NSMutableString *endingthemes = nil;
    if (((NSArray *)d[@"ending_theme"]).count > 0) {
        endingthemes = [NSMutableString new];
        [endingthemes appendString:@"\nEnding Themes:\n"];
        for (NSString *theme in (NSArray *)d[@"ending_theme"]){
            [endingthemes appendFormat:@"%@\n",theme];
        }
    }
    if (d[@"background"] != nil || ((NSString *)d[@"background"]).length > 0){
        background = [(NSString *)d[@"background"] convertHTMLtoAttStr];
    }
    else {
        background = [[NSAttributedString alloc] initWithString:@"None available"];
    }
    NSString *type = d[@"type"];
    NSNumber *score = d[@"members_score"];
    NSNumber *popularity = d[@"popularity_rank"];
    NSNumber *memberscount = d[@"members_count"];
    NSNumber *rank = d[@"rank"];
    NSNumber *favorites = d[@"favorited_count"];
    NSImage *posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[(NSString *)d[@"image_url"] stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",d[@"image_url"]]]];
    _infoviewposterimage.image = posterimage;
    [details appendString:[NSString stringWithFormat:@"Type: %@\n", type]];
    if (d[@"episodes"] == nil || ((NSNumber *)d[@"episodes"]).intValue == 0) {
        if (d[@"duration"] == nil  || ((NSNumber *)d[@"duration"]).intValue == 0){
            [details appendString:@"Episodes: Unknown\n"];
        }
        else{
            [details appendString:[NSString stringWithFormat:@"Episodes: Unknown (%i mins per episode)\n", ((NSNumber *)d[@"duration"]).intValue]];
        }
    }
    else {
        if (d[@"duration"] == nil  || ((NSNumber *)d[@"episodes"]).intValue == 0){
            [details appendString:[NSString stringWithFormat:@"Episodes: %i\n", ((NSNumber *)d[@"episodes"]).intValue]];
        }
        else{
            [details appendString:[NSString stringWithFormat:@"Episodes: %i (%i mins per episode)\n", ((NSNumber *)d[@"episodes"]).intValue, ((NSNumber *)d[@"duration"]).intValue]];
        }
    }
    [details appendString:[NSString stringWithFormat:@"Status: %@\n", d[@"status"]]];
    [details appendString:[NSString stringWithFormat:@"Genre: %@\n", genres]];
    if (producers) {
        [details appendString:[NSString stringWithFormat:@"Producers: %@\n", producers]];
    }
    if (d[@"classification"] != nil) {
        [details appendString:[NSString stringWithFormat:@"Classification: %@\n", d[@"classification"]]];
    }
    if (d[@"members_score"] != nil || ((NSNumber *)d[@"members_score"]).intValue > 0) {
        if (rank.intValue > 0) {
            [details appendString:[NSString stringWithFormat:@"Score: %f (%i users, ranked %i)\n", score.floatValue, memberscount.intValue, rank.intValue]];
        }
        else {
            [details appendString:[NSString stringWithFormat:@"Score: %f (%i users)\n", score.floatValue, memberscount.intValue]];
        }
    }
    if (popularity.intValue > 0) {
        [details appendString:[NSString stringWithFormat:@"Popularity: %i\n", popularity.intValue]];
    }
    if (favorites.intValue > 0) {
        [details appendString:[NSString stringWithFormat:@"Favorited: %i times\n", favorites.intValue]];
    }
    if (openingthemes) {
        [details appendString:openingthemes];
    }
    if (endingthemes) {
        [details appendString:endingthemes];
    }
    NSString *synopsis = d[@"synopsis"];
    _infoviewdetailstextview.string = details;
    [_infoviewsynopsistextview.textStorage setAttributedString:[synopsis convertHTMLtoAttStr]];
    [_infoviewbackgroundtextview.textStorage setAttributedString:background];
    // Fix textview text color
    _infoviewdetailstextview.textColor = NSColor.controlTextColor;
    _infoviewsynopsistextview.textColor = NSColor.controlTextColor;
    _infoviewbackgroundtextview.textColor = NSColor.controlTextColor;
    // Fix scrolling
    if (!_selectedinfo){
        [self fixtextviewscrollposition];
    }
    [self fixtextviewscrollposition];
    // Show buttons?
    [self showbuttons:d];
    [_mw loadmainview];
    [self setButtonPositions];
    _selectedinfo = d;
}

- (void)showbuttons:(NSDictionary *)d {
    if (d[@"recommendations"]){
        if ([(NSArray *)d[@"recommendations"] count] > 0){
            _recommendedtitlebutton.hidden = NO;
        }
        else {
            _recommendedtitlebutton.hidden = YES;
        }
    }
    else {
        _recommendedtitlebutton.hidden = YES;
    }
    if (((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"donated"]).boolValue) {
        if (d[@"manga_adaptations"]){
            if ([(NSArray *)d[@"manga_adaptations"] count] > 0){
                _sourcematerialbutton.hidden = NO;
            }
            else {
                _sourcematerialbutton.hidden = YES;
            }
        }
        else {
            _sourcematerialbutton.hidden = YES;
        }
        
    }
    else {
        _sourcematerialbutton.hidden = YES;
    }
    if (self.type == 0 && _steampopupviewcontroller.streamsexist) {
        _streambutton.hidden = NO;
    }
    else {
        _streambutton.hidden = YES;
    }
    [self showhidewebmenus];
}

- (void)fixtextviewscrollposition {
    [_infoviewdetailstextview scrollToBeginningOfDocument:self];
    [_infoviewsynopsistextview scrollToBeginningOfDocument:self];
    [_infoviewbackgroundtextview scrollToBeginningOfDocument:self];
}

- (void)populateMangaInfoView:(id)object{
    NSDictionary *d = object;
    NSMutableString *titles = [NSMutableString new];
    NSMutableString *details = [NSMutableString new];
    NSMutableString *genres = [NSMutableString new];
    NSAttributedString *background;
    _infoviewtitle.stringValue = d[@"title"];
    NSDictionary *dtitles =  d[@"other_titles"];
    NSMutableArray *othertitles = [NSMutableArray new];
    if (dtitles[@"english"] != nil){
        NSArray *e = dtitles[@"english"];
        for (NSString *etitle in e){
            [othertitles addObject:etitle];
        }
    }
    if (dtitles[@"japanese"] != nil){
        NSArray *j = dtitles[@"japanese"];
        for (NSString *jtitle in j){
            [othertitles addObject:jtitle];
        }
    }
    if (dtitles[@"synonyms"] != nil){
        NSArray *syn = dtitles[@"synonyms"];
        for (NSString *stitle in syn){
            [othertitles addObject:stitle];
        }
    }
    [titles appendString:[Utility appendstringwithArray:othertitles]];
    _infoviewalttitles.stringValue = titles;
    if (d[@"genres"]!= nil){
        NSArray *genresa = d[@"genres"];
        [genres appendString:[Utility appendstringwithArray:genresa]];
    }
    else{
        [genres appendString:@"None"];
    }
    background = [[NSAttributedString alloc] initWithString:@"None available"];
    NSString *type = d[@"type"];
    NSNumber *score = d[@"members_score"];
    NSNumber *popularity = d[@"popularity_rank"];
    NSNumber *memberscount = d[@"members_count"];
    NSNumber *rank = d[@"rank"];
    NSNumber *favorites = d[@"favorited_count"];
    NSImage *posterimage = [Utility loadImage:[NSString stringWithFormat:@"%@.jpg",[[(NSString *)d[@"image_url"] stringByReplacingOccurrencesOfString:@"https://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@"-"]] withAppendPath:@"imgcache" fromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",d[@"image_url"]]]];
    _infoviewposterimage.image = posterimage;
    [details appendString:[NSString stringWithFormat:@"Type: %@\n", type]];
    if (d[@"chapters"] == nil || ((NSNumber *)d[@"chapters"]).intValue  == 0) {
        if (d[@"duration"] == nil && d[@"duration"] == [NSNull null]){
            [details appendString:@"Chapters: Unknown\n"];
        }
    }
    else {
        [details appendString:[NSString stringWithFormat:@"Chapters: %i \n", ((NSNumber *)d[@"chapters"]).intValue]];
    }
    if (d[@"volumes"] == nil || ((NSNumber *)d[@"volumes"]).intValue == 0){
        [details appendString:@"Volumes: Unknown\n"];
    }
    else {
        [details appendString:[NSString stringWithFormat:@"Volumes: %i \n", ((NSNumber *)d[@"volumes"]).intValue]];
    }
    [details appendString:[NSString stringWithFormat:@"Status: %@\n", d[@"status"]]];
    [details appendString:[NSString stringWithFormat:@"Genre: %@\n", genres]];
    if (d[@"members_score"] !=nil || ((NSNumber *)d[@"members_score"]).intValue) {
        if (rank.intValue > 0) {
            [details appendString:[NSString stringWithFormat:@"Score: %f (%i users, ranked %i)\n", score.floatValue, memberscount.intValue, rank.intValue]];
        }
        else {
            [details appendString:[NSString stringWithFormat:@"Score: %f (%i users)\n", score.floatValue, memberscount.intValue]];
        }
    }
    if (popularity.intValue > 0) {
        [details appendString:[NSString stringWithFormat:@"Popularity: %i\n", popularity.intValue]];
    }
    if (favorites.intValue > 0) {
        [details appendString:[NSString stringWithFormat:@"Favorited: %i times\n", favorites.intValue]];
    }
    NSString *synopsis = d[@"synopsis"];
    _infoviewdetailstextview.string = details;
    [_infoviewsynopsistextview.textStorage setAttributedString:[synopsis convertHTMLtoAttStr]];
    [_infoviewbackgroundtextview.textStorage setAttributedString:background];
    // Fix textview text color
    _infoviewdetailstextview.textColor = NSColor.controlTextColor;
    _infoviewsynopsistextview.textColor = NSColor.controlTextColor;
    _infoviewbackgroundtextview.textColor = NSColor.controlTextColor;
    // Show buttons?
    [self showbuttons:d];
    [_mw loadmainview];
    [self setButtonPositions];
    _selectedinfo = d;
}

- (IBAction)viewonmal:(id)sender {
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (_type == AnimeType){
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/anime/%i",_selectedid]]];
            }
            else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/manga/%i",_selectedid]]];
            }
            break;
        }
        case 2: {
            if (_type == AnimeType){
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/anime/%i",_selectedid]]];
            }
            else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://kitsu.io/manga/%i",_selectedid]]];
            }
            break;
        }
        default:
            break;
    }

}

- (IBAction)viewreviews:(id)sender {
    if (!_mw.reviewwindow){
        _mw.reviewwindow = [ReviewWindow new];
    }
    [_mw.reviewwindow loadReview:_selectedid type:_type title:_infoviewtitle.stringValue];
    [_mw.reviewwindow.window makeKeyAndOrderFront:self];
}

- (IBAction)showrecommendedtitlepopover:(id)sender {
    if (_otherpopoverviewcontroller.selectedid == 0){
        [_otherpopoverviewcontroller viewDidLoad];
    }
    _otherpopoverviewcontroller.popovertitle.stringValue = @"Recommended Titles";
    [_otherpopoverviewcontroller loadTitles:_selectedinfo[@"recommendations"] selectedid:_selectedid type:_type];
    [_othertitlepopover showRelativeToRect:_recommendedtitlebutton.bounds ofView:_recommendedtitlebutton preferredEdge:NSMaxYEdge];
}

- (IBAction)showadaptationspopover:(id)sender {
    if (_otherpopoverviewcontroller.selectedid == 0){
        [_otherpopoverviewcontroller viewDidLoad];
    }
    _otherpopoverviewcontroller.popovertitle.stringValue = @"Manga Adaptations";
    [_otherpopoverviewcontroller loadTitles:_selectedinfo[@"manga_adaptations"] selectedid:_selectedid type:1];
    [_othertitlepopover showRelativeToRect:_sourcematerialbutton.bounds ofView:_sourcematerialbutton preferredEdge:NSMaxYEdge];
}

- (IBAction)viewstreams:(id)sender {
    [_streampopover showRelativeToRect:_streambutton.bounds ofView:_streambutton preferredEdge:NSMaxYEdge];
}

- (void)setButtonPositions {
    // Sets the position of the recommended titles, source material and sites to watch title buttons
    NSMutableArray *buttonarray = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        NSButton *btn;
        switch (i){
            case 0:
                btn = _recommendedtitlebutton;
                break;
            case 1:
                btn = _sourcematerialbutton;
                break;
            case 2:
                btn = _streambutton;
                break;
            default:
                break;
        }
        if (!btn.hidden) {
            [buttonarray addObject:btn];
        }
    }
    for (int i = 0; i < buttonarray.count; i++) {
        NSButton *btn = buttonarray[i];
        CGPoint btnorigin = btn.frame.origin;
        switch (i) {
            case 0:
                [btn setFrameOrigin:NSMakePoint(btnorigin.x, 109)];
                break;
            case 1:
                [btn setFrameOrigin:NSMakePoint(btnorigin.x, 78)];
                break;
            case 2:
                [btn setFrameOrigin:NSMakePoint(btnorigin.x, 45)];
                break;
            default:
                break;
        }
    }
}

- (IBAction)openpeoplebrowser:(id)sender {
    if (!_cbrowser) {
        _cbrowser = [CharactersBrowser new];
    }
    [_cbrowser.window makeKeyAndOrderFront:self];
    if (_cbrowser.selectedtitleid != _selectedid) {
        _cbrowser.window.title = [NSString stringWithFormat:@"People Browser - %@",_infoviewtitle.stringValue];
        _cbrowser.selectedtitle = _infoviewtitle.stringValue;
        [_cbrowser retrievestafflist:self.selectedid];
    }
}

- (IBAction)searchsite:(id)sender {
    NSMenuItem *siteitem = (NSMenuItem *)sender;
    NSURL *openurl;
    switch (siteitem.tag) {
        case 1:
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://anidb.net/perl-bin/animedb.pl?show=animelist&amp;adb.search=%@&amp;noalias=1&amp;do.update=update",[Utility urlEncodeString:_infoviewtitle.stringValue]]];
            break;
        case 2:
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.animenewsnetwork.com/search?q=%@",[Utility urlEncodeString:_infoviewtitle.stringValue]]];
            break;
        case 3:
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.mangaupdates.com/search.html?search=%@",[Utility urlEncodeString:_infoviewtitle.stringValue]]];
            break;
        case 4: {
            if (_type == MALAnime) {
                openurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", @"https://www.reddit.com/search?sort=new&amp;q=subreddit%3Aanime%20title%3A", [Utility urlEncodeString:_infoviewtitle.stringValue], @"%20episode%20discussion"]];
            }
            else {
                openurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", @"https://www.reddit.com/search?sort=new&amp;q=subreddit%3Amanga%20title%3A", [Utility urlEncodeString:_infoviewtitle.stringValue], @"%20ch"]];
            }
            break;
        }
        case 5:
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://tvtropes.org/pmwiki/search_result.php?q=%@",[Utility urlEncodeString:_infoviewtitle.stringValue]]];
            break;
        case 6:
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://en.wikipedia.org/wiki/Special:Search?search=%@",[Utility urlEncodeString:_infoviewtitle.stringValue]]];
            break;
        case 7: {
            NSString *tmptitle;
            if (((NSArray *)_selectedinfo[@"other_titles"][@"japanese"]).count > 0) {
                tmptitle = _selectedinfo[@"other_titles"][@"japanese"][0];
            }
            else {
                tmptitle = _infoviewtitle.stringValue;
            }
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://dic.pixiv.net/search?query=%@",[Utility urlEncodeString:tmptitle]]];
            break;
        }
        case 8:
            openurl = [NSURL URLWithString:[NSString stringWithFormat:@"https://en-dic.pixiv.net/search?query=%@",[Utility urlEncodeString:_infoviewtitle.stringValue]]];
            break;
        default:
            return;
    }
    [[NSWorkspace sharedWorkspace] openURL:openurl];
}
- (void)showhidewebmenus {
    if (_type == MALAnime) {
        _anidbmenuitem.hidden = NO;
        _bakaupdatesmenuitem.hidden = YES;
    }
    else {
        _anidbmenuitem.hidden = YES;
        _bakaupdatesmenuitem.hidden = NO;
    }
}
@end
