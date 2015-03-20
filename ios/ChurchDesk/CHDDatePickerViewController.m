//
//  CHDDatePickerViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <SHPCalendarPicker/SHPCalendarPickerView.h>
#import "CHDDatePickerViewController.h"
#import "SHPCalendarPickerView+ChurchDesk.h"

static CGFloat kCalendarHeight = 330.0f;

typedef NS_ENUM(NSUInteger, CHDDatePickerSelectedControl) {
    chdDatePickerDateSelection,
    chdDatePickerTimeSelection,
};

@interface CHDDatePickerViewController () <SHPCalendarPickerViewDelegate>
@property (nonatomic, strong) NSDate *date;



@property (nonatomic, strong) NSDate *dateSelected;
@property (nonatomic, strong) NSDate *timeSelected;
@property (nonatomic) BOOL allDaySelected;
@property (nonatomic) BOOL allDaySelectable;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) SHPCalendarPickerView *calendarPicker;

@property (nonatomic, strong) UIView *timePickerContainerView;
@property (nonatomic, strong) UIDatePicker *timePicker;
@property (nonatomic, strong) UIView *allDayRowView;
@property (nonatomic, strong) UILabel *allDayLabel;
@property (nonatomic, strong) UISwitch *allDaySwitch;

@property (nonatomic, strong) UIView *toggleButtonView;
@property (nonatomic, strong) UIButton *selectDateButton;
@property (nonatomic, strong) UIButton *selectTimeButton;

@property (nonatomic) CHDDatePickerSelectedControl selectedControl;
@end

@implementation CHDDatePickerViewController
-(instancetype)initWithDate: (NSDate*) date allDay: (BOOL) allDay canSelectAllDay: (BOOL) allDaySelecable {
    self = [super init];
    if(self){
        if(date) {
            self.dateSelected = [date copy];
            self.timeSelected = [date copy];
        }
        self.allDaySelected = allDay;
        self.allDaySelectable = allDaySelecable;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor shpui_colorWithHexValue:0xe9e9e9];

    [self setupSubviews];
    [self makeConstraints];

    if(self.dateSelected) {
        [self.calendarPicker setSelectedDates:@[self.dateSelected]];
    }
    if(self.timeSelected) {
        [self.timePicker setDate:self.timeSelected];
    }

    [self makeBindings];
    if(self.dateSelected){
        self.selectedControl = chdDatePickerTimeSelection;
    }else{
        self.selectedControl = chdDatePickerDateSelection;
    }
    self.allDaySwitch.on = self.allDaySelected;
}

- (void) setupSubviews {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];

    [saveButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [saveButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = saveButton;

    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.calendarPicker];

    [self.containerView addSubview:self.timePickerContainerView];

    [self.timePickerContainerView addSubview:self.timePicker];
    [self.timePickerContainerView addSubview:self.allDayRowView];

    [self.allDayRowView addSubview:self.allDayLabel];
    [self.allDayRowView addSubview:self.allDaySwitch];

    [self.view addSubview:self.toggleButtonView];
    [self.toggleButtonView addSubview:self.selectDateButton];
    [self.toggleButtonView addSubview:self.selectTimeButton];
}

- (void) makeConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(kCalendarHeight));
    }];

    [self.calendarPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.left.right.equalTo(self.containerView);
        make.height.equalTo(@(kCalendarHeight));
    }];

    [self.timePickerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.containerView);
    }];

    [self.timePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.timePickerContainerView);
        make.height.equalTo(@280);
    }];

    [self.allDayRowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timePicker.mas_bottom);
        make.left.right.equalTo(self.timePickerContainerView);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.timePickerContainerView);
    }];

    [self.allDayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.allDayRowView);
        make.left.equalTo(self.allDayRowView).offset(15);
    }];

    [self.allDaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.allDayRowView);
        make.right.equalTo(self.allDayRowView).offset(-15);
    }];

    [self.toggleButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.calendarPicker.mas_bottom).offset(35);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@50);
    }];

    [self.selectDateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.equalTo(self.toggleButtonView);
        make.width.equalTo(self.toggleButtonView).multipliedBy(0.5);
    }];

    [self.selectTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.height.equalTo(self.toggleButtonView);
        make.width.equalTo(self.toggleButtonView).multipliedBy(0.5);
    }];
}

- (void) makeBindings {
    [self.selectDateButton rac_liftSelector:@selector(setBackgroundColor:) withSignals:[RACObserve(self.selectDateButton, selected) map:^id(NSNumber *iSelected) {
        if(iSelected.boolValue){
            return [UIColor whiteColor];
        }
        return [UIColor shpui_colorWithHexValue:0xcfcfcf];
    }], nil];

    [self.selectTimeButton rac_liftSelector:@selector(setBackgroundColor:) withSignals:[RACObserve(self.selectTimeButton, selected) map:^id(NSNumber *iSelected) {
        if(iSelected.boolValue){
            return [UIColor whiteColor];
        }
        return [UIColor shpui_colorWithHexValue:0xcfcfcf];
    }], nil];

    RACSignal *datePickerSelectedSignal = [RACObserve(self, selectedControl) map:^id(NSNumber *iSelected) {
        return @( iSelected.unsignedIntegerValue == chdDatePickerDateSelection );
    }];

    RACSignal *timePickerSelectedSignal = [RACObserve(self, selectedControl) map:^id(NSNumber *iSelected) {
        return @( iSelected.unsignedIntegerValue == chdDatePickerTimeSelection );
    }];

    [self.selectDateButton rac_liftSelector:@selector(setSelected:) withSignals:datePickerSelectedSignal, nil];

    [self.selectTimeButton rac_liftSelector:@selector(setSelected:) withSignals:timePickerSelectedSignal, nil];

    [self rac_liftSelector:@selector(setSelectedControl:) withSignals:[RACSignal merge:@[[[self.selectDateButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return @(chdDatePickerDateSelection);
    }], [[self.selectTimeButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return @(chdDatePickerTimeSelection);
    }]]], nil];

    [self.timePickerContainerView rac_liftSelector:@selector(setHidden:) withSignals:[timePickerSelectedSignal map:^id(NSNumber *iSelected) {
        return @(!iSelected.boolValue);
    }], nil];

    RAC(self, allDaySelected) = [[self.allDaySwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *aSwitch) {
        return @(aSwitch.isOn);
    }];

    RAC(self, timeSelected) = [[self.timePicker rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UIDatePicker *datePicker) {
        return datePicker.date;
    }];

    RACSignal *dateSelectedSignal = RACObserve(self, dateSelected);

    [self.allDayRowView rac_liftSelector:@selector(setHidden:) withSignals:[RACObserve(self, allDaySelectable) not], nil];

    [self rac_liftSelector:@selector(setSelectedControl:) withSignals:[dateSelectedSignal map:^id(id value) {
        return @(chdDatePickerTimeSelection);
    }], nil];

    [self shprac_liftSelector:@selector(selectedDateChanged) withSignal:dateSelectedSignal];
    [self shprac_liftSelector:@selector(selectedTimeChanged) withSignal:[RACSignal merge:@[RACObserve(self, allDaySelected), RACObserve(self, timeSelected)]]];

    RACSignal *canSaveSignal = [RACSignal combineLatest:@[dateSelectedSignal, RACObserve(self, timeSelected), RACObserve(self, allDaySelected)] reduce:^id(NSDate *date, NSDate *time, NSNumber *iAllDay) {
        return @( (date != nil && (time != nil || iAllDay.boolValue) ) );
    }];

    RAC(self.navigationItem.rightBarButtonItem, enabled) = canSaveSignal;
}

#pragma mark - SHPCalendarPickerViewDelegate

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didSelectDate:(NSDate *)date {
    self.dateSelected = date;
}

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView willAnimateToMonth:(NSDate *)date {}

#pragma mark - Actions

- (void) cancelAction: (id) sender {
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveAction: (id) sender {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned dateUnitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    unsigned timeUnitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;

    NSDateComponents *dateComponents = [calendar components:dateUnitFlags fromDate:self.dateSelected];

    if(self.timeSelected) {
        NSDateComponents *timeComponents = [calendar components:timeUnitFlags fromDate:self.timeSelected];

        [dateComponents setHour:timeComponents.hour];
        [dateComponents setMinute:timeComponents.minute];
    }
    self.allDay = self.allDaySelected;
    self.date = [calendar dateFromComponents:dateComponents];

    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Set toggle button titles
-(void) selectedDateChanged {
    NSString *newTitle = nil;
    if(!self.dateSelected){
        newTitle = NSLocalizedString(@"Date", @"");
    }else if(self.dateSelected){
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        NSLocale *locale = [NSLocale currentLocale];

        //Set date format Templates
        NSString *dateComponents = @"ddMMMM";
        NSString *dateTemplate = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:locale];
        [dateFormatter setDateFormat:dateTemplate];

        //Localize the date
        dateFormatter.locale = locale;

        newTitle = [dateFormatter stringFromDate:self.dateSelected];
    }
    [self.selectDateButton setTitle:newTitle forState:UIControlStateNormal];
}
-(void) selectedTimeChanged {
    NSString *title = nil;
    if(self.allDaySelected){
        title = NSLocalizedString(@"All day", @"");
    }else if(self.timeSelected){
        NSDateFormatter *timeFormatter = [NSDateFormatter new];
        NSLocale *locale = [NSLocale currentLocale];

        //Set date format Templates
        NSString *timeComponents = @"jjmm";
        NSString *timeTemplate = [NSDateFormatter dateFormatFromTemplate:timeComponents options:0 locale:locale];

        [timeFormatter setDateFormat:timeTemplate];

        //Localize the date
        timeFormatter.locale = locale;

        title = [timeFormatter stringFromDate:self.timeSelected];
    }else{
        title = NSLocalizedString(@"Time", @"");
    }
    [self.selectTimeButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Lazy initialization
- (UIView*) containerView {
    if(!_containerView){
        _containerView = [UIView new];
    }
    return _containerView;
}

- (SHPCalendarPickerView *)calendarPicker {
    if (!_calendarPicker) {
        _calendarPicker = [SHPCalendarPickerView chd_calendarPickerView];
        _calendarPicker.delegate = self;
    }
    return _calendarPicker;
}

- (UIView *) timePickerContainerView{
    if(!_timePickerContainerView){
        _timePickerContainerView = [UIView new];
        _timePickerContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _timePickerContainerView;
}

- (UIDatePicker *) timePicker {
    if(!_timePicker){
        _timePicker = [[UIDatePicker alloc] init];
        _timePicker.datePickerMode = UIDatePickerModeTime;
        _timePicker.minuteInterval = 5;
    }
    return _timePicker;
}

- (UIView *) allDayRowView{
    if(!_allDayRowView){
        _allDayRowView = [UIView new];
        _allDayRowView.backgroundColor = [UIColor whiteColor];
    }
    return _allDayRowView;
}

- (UILabel *) allDayLabel {
    if(!_allDayLabel){
        _allDayLabel = [UILabel new];
        _allDayLabel.text = NSLocalizedString(@"All day", @"");
        _allDayLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:16];
        _allDayLabel.textColor = [UIColor darkTextColor];
    }
    return _allDayLabel;
}

- (UISwitch*) allDaySwitch {
    if(!_allDaySwitch){
        _allDaySwitch = [UISwitch new];
    }
    return _allDaySwitch;
}


-(UIView*) toggleButtonView {
    if(!_toggleButtonView){
        _toggleButtonView = [UIView new];
        _toggleButtonView.backgroundColor = [UIColor whiteColor];
        _toggleButtonView.layer.cornerRadius = 2.0f;
        _toggleButtonView.layer.masksToBounds = YES;
    }
    return _toggleButtonView;
}

-(UIButton*) selectDateButton {
    if(!_selectDateButton){
        _selectDateButton = [UIButton new];
        [_selectDateButton setTitleColor:[UIColor shpui_colorWithHexValue:0x717171] forState:UIControlStateNormal];
        [_selectDateButton setTitleColor:[UIColor chd_blueColor] forState:UIControlStateSelected];
        _selectDateButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
    }
    return _selectDateButton;
}
-(UIButton*) selectTimeButton {
    if(!_selectTimeButton){
        _selectTimeButton = [UIButton new];
        [_selectTimeButton setTitleColor:[UIColor shpui_colorWithHexValue:0x717171] forState:UIControlStateNormal];
        [_selectTimeButton setTitleColor:[UIColor chd_blueColor] forState:UIControlStateSelected];
        _selectTimeButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
    }
    return _selectTimeButton;
}
@end
