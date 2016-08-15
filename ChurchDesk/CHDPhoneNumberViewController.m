//
//  CHDPhoneNumberViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 02/08/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDPhoneNumberViewController.h"
#import "NBPhoneNumberUtil.h"

@interface CHDPhoneNumberViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) UIButton *countryCodeButton;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *deleteNumberButton;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *receiverView;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, retain) NSString *selectedCountryCode;
@end

@implementation CHDPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    // Do any additional setup after loading the view.
}

#pragma mark - Lazy initialization

-(void) makeViews {
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
    [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    [self.view addSubview:self.countryCodeButton];
    [self.view addSubview:self.textField];
    [self.textField becomeFirstResponder];
    [self.view addSubview:self.deleteNumberButton];
}

-(void) makeConstraints {
    UIView *containerView = self.view;

    [self.countryCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(20);
        make.top.equalTo(containerView).with.offset(50);
        make.width.equalTo(@55);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(80);
        make.top.equalTo(containerView).with.offset(50);
        make.right.equalTo(containerView).offset(-20.0f);
        make.height.equalTo(@32);
    }];
    
    [self.deleteNumberButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView.mas_centerX);
        make.top.equalTo(containerView).with.offset(120);
        make.width.equalTo(@100);
    }];
}

-(void)makeBindings{
    if (_phoneNumber.length > 1) {
        _deleteNumberButton.hidden = false;
       [_countryCodeButton setTitle:[self getCountryCode:_phoneNumber] forState:UIControlStateNormal] ;
        _textField.text = [_phoneNumber stringByReplacingOccurrencesOfString:_countryCodeButton.titleLabel.text withString:@""];
    }
    else{
        _deleteNumberButton.hidden = true;
        [_countryCodeButton setTitle:[self getDefaultCountryCode] forState:UIControlStateNormal];
    }
    [self isNumberValid:_phoneNumber];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)countryCodeButton {
    if (!_countryCodeButton) {
        _countryCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_countryCodeButton setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        _countryCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_countryCodeButton addTarget:self action:@selector(showCountryOptions) forControlEvents:UIControlEventTouchUpInside];
        [[_countryCodeButton layer] setBorderWidth:2.0f];
        [[_countryCodeButton layer] setBorderColor:[UIColor chd_lightGreyColor].CGColor];
    }
    return _countryCodeButton;
}

- (UIButton *)deleteNumberButton {
    if (!_deleteNumberButton) {
        _deleteNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteNumberButton setTitleColor:[UIColor chd_redColor] forState:UIControlStateNormal];
        _deleteNumberButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_deleteNumberButton addTarget:self action:@selector(deleteNumber) forControlEvents:UIControlEventTouchUpInside];
        [_deleteNumberButton setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
    }
    return _deleteNumberButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:20];
        _textField.textColor = [UIColor chd_textDarkColor];
        _textField.returnKeyType = UIReturnKeyDefault;
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _textField.delegate = self;
        _textField.placeholder = self.title;
        [_textField addTarget:self
                      action:@selector(textFieldDidChange)
            forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

#pragma mark - Actions
-(void) rightBarButtonTouch{
    [self.view endEditing:YES];
    NSString *updatedPhoneNumber = [NSString stringWithFormat:@"%@%@", _countryCodeButton.titleLabel.text, _textField.text];
    self.phoneNumber = updatedPhoneNumber;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteNumber{
    self.phoneNumber = @"";
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showCountryOptions{
    [self.view endEditing:YES];
    if(!_receiverView){
        [Heap track:@"Send to popup shown"];
        _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundButton.frame = self.view.superview.frame;
        [_backgroundButton addTarget:self action:@selector(removeCountryView) forControlEvents:UIControlEventTouchUpInside];
        _backgroundButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self.view addSubview:_backgroundButton];
        
        _receiverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)] ;
        _receiverView.center = self.view.superview.center;
        _receiverView.userInteractionEnabled = TRUE;
        _receiverView.backgroundColor = [UIColor whiteColor];
        _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        
        UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake ( 0, 20, 300, 25)];
        selectLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:20];
        selectLabel.textAlignment = NSTextAlignmentCenter;
        selectLabel.textColor = [UIColor chd_textDarkColor];
        [_receiverView addSubview:selectLabel];
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        doneButton.frame = CGRectMake ( 100, 340, 100, 50);
        [_receiverView addSubview:doneButton];
        [self.view addSubview:_receiverView];
            selectLabel.text = NSLocalizedString(@"Country", @"");
            _pickerView = [[UIPickerView alloc] init];
            [_pickerView setDataSource: self];
            [_pickerView setDelegate: self];
            [_pickerView setFrame:CGRectMake(10, 50, 280, 290)];
            _pickerView.showsSelectionIndicator = YES;
            [_receiverView addSubview: _pickerView];
            [doneButton addTarget:self action:@selector(donePickerPressed) forControlEvents:UIControlEventTouchUpInside];
        //manually setting selected country
        if ([[[self getCountryCodes] allValues] containsObject:_countryCodeButton.titleLabel.text]) {
            NSUInteger indexOfCountryCode = [[self allCountryNames] indexOfObject:[[[self getCountryCodes] allKeysForObject:_countryCodeButton.titleLabel.text] objectAtIndex:0]];
            [self.pickerView selectRow:indexOfCountryCode inComponent:0 animated:YES];
        }
        
        [UIView animateWithDuration:0.3/1.5 animations:^{
            _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    _receiverView.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
    }
}

-(void) donePickerPressed{
    if (_selectedCountryCode.length > 0) {
        [_countryCodeButton setTitle:_selectedCountryCode forState:UIControlStateNormal];
    }
    
    [self removeCountryView];
}

-(void) removeCountryView{
    [_pickerView removeFromSuperview];
    _pickerView = nil;
    [_receiverView removeFromSuperview];
    _receiverView = nil;
    [_backgroundButton removeFromSuperview];
    _backgroundButton = nil;
    [_textField becomeFirstResponder];
    [self textFieldDidChange];
}

-(NSString *)getCountryCode :(NSString *)phoneNumber{
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSString *countryCode = [NSString stringWithFormat:@"+%@", [phoneUtil extractCountryCode:phoneNumber nationalNumber:nil]];
    if (countryCode.length > 1) {
        return countryCode;
    }
    else{
        return [self getDefaultCountryCode];
    }
}

-(NSString *)getDefaultCountryCode{
    NSString *defaultCountry = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:[[NSUserDefaults standardUserDefaults]objectForKey:@"country"] ];
    NSString * defaultCountryCode = [[self getCountryCodes] valueForKey:defaultCountry];
    if (defaultCountryCode) {
       return defaultCountryCode;
    }
    else{
        return @"+1";
    }
}

-(void)isNumberValid :(NSString *)phoneNumber{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSLog(@"phone number %@", phoneNumber);
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phoneNumber
                                 defaultRegion:@"AT" error:&anError];
    if (anError == nil) {
        //Change the state of the create button
        self.navigationItem.rightBarButtonItem.enabled = [phoneUtil isValidNumber:myNumber];
    } else {
        NSLog(@"Error : %@", [anError localizedDescription]);
    }

}

#pragma mark - textfield delegate
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

-(void)textFieldDidChange{
    NSString *phoneString = [NSString stringWithFormat:@"%@%d", _countryCodeButton.titleLabel.text, _textField.text.intValue];
    [self isNumberValid:phoneString];
}
#pragma mark - Picker delegates
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
        return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
        return [self getCountryCodes].allKeys.count;
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *countryName = [[self allCountryNames] objectAtIndex:row];
    NSString *returnString = [NSString stringWithFormat:@"%@  %@", countryName, [[self getCountryCodes] valueForKey:countryName]];
    return returnString;
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedCountryCode = [[self getCountryCodes] valueForKey:[[self allCountryNames] objectAtIndex:row]];
}

-(NSArray *)allCountryNames {
    return [[[self getCountryCodes] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
// list of all countries
- (NSDictionary *)getCountryCodes {
    NSDictionary * dialingCodes = @ {
        @ "Abkhazia"                                     : @ "+840" ,
        @ "Afghanistan"                                   : @ "+93" ,
        @ "Albania"                                       : @ "+355" ,
        @ "Algeria"                                       : @ "+213" ,
        @ "American Samoa"                               : @ "+1684" ,
        @ "Andorra"                                       : @ "+376" ,
        @ "Angola"                                       : @ "+244" ,
        @ "Anguilla"                                     : @ "+1264" ,
        @ "Antigua and Barbuda"                           : @ "+1268" ,
        @ "Argentina"                                     : @ "+54" ,
        @ "Armenia"                                       : @ "+374" ,
        @ "Aruba"                                         : @ "+297" ,
        @ "Ascension"                                     : @ "+247" ,
        @ "Australia"                                     : @ "+61" ,
        @ "Australian External Territories"               : @ "+672" ,
        @ "Austria"                                       : @ "+43" ,
        @ "Azerbaijan"                                   : @ "+994" ,
        @ "Bahamas"                                       : @ "+1242" ,
        @ "Bahrain"                                       : @ "+973" ,
        @ "Bangladesh"                                   : @ "+880" ,
        @ "Barbados"                                     : @ "+1246" ,
        @ "Barbuda"                                       : @ "+1268" ,
        @ "Belarus"                                       : @ "+375" ,
        @ "Belgium"                                       : @ "+32" ,
        @ "Belize"                                       : @ "+501" ,
        @ "Benin"                                         : @ "+229" ,
        @ "Bermuda"                                       : @ "+1441" ,
        @ "Bhutan"                                       : @ "+975" ,
        @ "Bolivia"                                       : @ "+591" ,
        @ "Bosnia and Herzegovina"                       : @ "+387" ,
        @ "Botswana"                                     : @ "+267" ,
        @ "Brazil"                                       : @ "+55" ,
        @ "British Indian Ocean Territory"               : @ "+246" ,
        @ "British Virgin Islands"                       : @ "+1284" ,
        @ "Brunei"                                       : @ "+673" ,
        @ "Bulgaria"                                     : @ "+359" ,
        @ "Burkina Faso"                                 : @ "+226" ,
        @ "Burundi"                                       : @ "+257" ,
        @ "Cambodia"                                     : @ "+855" ,
        @ "Cameroon"                                     : @ "+237" ,
        @ "Canada"                                       : @ "+1" ,
        @ "Cape Verde"                                   : @ "+238" ,
        @ "Cayman Islands"                               : @ "+345" ,
        @ "Central African Republic"                     : @ "+236" ,
        @ "Chad"                                         : @ "+235" ,
        @ "Chile"                                         : @ "+56" ,
        @ "China"                                         : @ "+86" ,
        @ "Christmas Island"                             : @ "+61" ,
        @ "Cocos-Keeling Islands"                         : @ "+61" ,
        @ "Columbia"                                     : @ "+57" ,
        @ "Comoros"                                       : @ "+269" ,
        @ "Congo"                                         : @ "+242" ,
        @ "Congo, Dem. Rep. Of (Zaire)"                   : @ "+243" ,
        @ "Cook Islands"                                 : @ "+682" ,
        @ "Costa Rica"                                   : @ "+506" ,
        @ "Croatia"                                       : @ "+385" ,
        @ "Cuba"                                         : @ "+53" ,
        @ "Curacao"                                       : @ "+599" ,
        @ "Cyprus"                                       : @ "+537" ,
        @ "Czech Republic"                               : @ "+420" ,
        @ "Denmark"                                       : @ "+45" ,
        @ "Diego Garcia"                                 : @ "+246" ,
        @ "Djibouti"                                     : @ "+253" ,
        @ "Dominica"                                     : @ "+1767" ,
        @ "Dominican Republic"                           : @ "+1809" ,
        @ "Dominican Republic"                           : @ "+1829" ,
        @ "Dominican Republic"                           : @ "+1849" ,
        @ "East Timor"                                   : @ "+670" ,
        @ "Easter Island"                                 : @ "+56" ,
        @ "Ecuador"                                       : @ "+593" ,
        @ "Egypt"                                         : @ "+20" ,
        @ "El Salvador"                                   : @ "+503" ,
        @ "Equatorial Guinea"                             : @ "+240" ,
        @ "Eritrea"                                       : @ "+291" ,
        @ "Estonia"                                       : @ "+372" ,
        @ "Ethiopia"                                     : @ "+251" ,
        @ "Falkland Islands"                             : @ "+500" ,
        @ "Faroe Islands"                                 : @ "+298" ,
        @ "Fiji"                                         : @ "+679" ,
        @ "Finland"                                       : @ "+358" ,
        @ "France"                                       : @ "+33" ,
        @ "French Antilles"                               : @ "+596" ,
        @ "French Guiana"                                 : @ "+594" ,
        @ "French Polynesia"                             : @ "+689" ,
        @ "Gabon"                                         : @ "+241" ,
        @ "Gambia"                                       : @ "+220" ,
        @ "Georgia"                                       : @ "+995" ,
        @ "Germany"                                       : @ "+49" ,
        @ "Ghana"                                         : @ "+233" ,
        @ "Gibraltar"                                     : @ "+350" ,
        @ "Greece"                                       : @ "+30" ,
        @ "Greenland"                                     : @ "+299" ,
        @ "Granada"                                       : @ "+1473" ,
        @ "Guadeloupe"                                   : @ "+590" ,
        @ "Guam"                                         : @ "+1671" ,
        @ "Guatemala"                                     : @ "+502" ,
        @ "Guinea"                                       : @ "+224" ,
        @ "Guinea-Bissau"                                 : @ "+245" ,
        @ "Guiana"                                       : @ "+595" ,
        @ "Haiti"                                         : @ "+509" ,
        @ "Honduras"                                     : @ "+504" ,
        @ "Hong Kong SAR China"                           : @ "+852" ,
        @ "Hungary"                                       : @ "+36" ,
        @ "Island"                                       : @ "+354" ,
        @ "India"                                         : @ "+91" ,
        @ "Indonesia"                                     : @ "+62" ,
        @ "Iran"                                         : @ "+98" ,
        @ "Iraq"                                         : @ "+964" ,
        @ "Ireland"                                       : @ "+353" ,
        @ "Israel"                                       : @ "+972" ,
        @ "Italy"                                         : @ "+39" ,
        @ "Ivory Coast"                                   : @ "+225" ,
        @ "Jamaica"                                       : @ "+1876" ,
        @ "Japan"                                         : @ "+81" ,
        @ "Jordan"                                       : @ "+962" ,
        @ "Kazakhstan"                                   : @ "+7" ,
        @ "Kenya"                                         : @ "+254" ,
        @ "Kiribati"                                     : @ "+686" ,
        @ "Kuwait"                                       : @ "+965" ,
        @ "Kyrgyzstan"                                   : @ "+996" ,
        @ "Lao"                                         : @ "+856" ,
        @ "Latvia"                                       : @ "+371" ,
        @ "Lebanon"                                       : @ "+961" ,
        @ "Lesotho"                                       : @ "+266" ,
        @ "Liberia"                                       : @ "+231" ,
        @ "Libya"                                         : @ "+218" ,
        @ "Liechtenstein"                                 : @ "+423" ,
        @ "Lithuania"                                     : @ "+370" ,
        @ "Luxembourg"                                   : @ "+352" ,
        @ "Macau SAR China"                               : @ "+853" ,
        @ "Macedonia"                                     : @ "+389" ,
        @ "Madagascar"                                   : @ "+261" ,
        @ "Malawi"                                       : @ "+265" ,
        @ "Malaysia"                                     : @ "+60" ,
        @ "Maldives"                                     : @ "+960" ,
        @ "Mali"                                         : @ "+223" ,
        @ "Malta"                                         : @ "+356" ,
        @ "Marshall Islands"                             : @ "+692" ,
        @ "Martinique"                                   : @ "+596" ,
        @ "Mauritania"                                   : @ "+222" ,
        @ "Mauritius"                                     : @ "+230" ,
        @ "Mayotte"                                       : @ "+262" ,
        @ "Mexico"                                       : @ "+52" ,
        @ "Micronesia"                                   : @ "+691" ,
        @ "Midway Island"                                 : @ "+1808" ,
        @ "Micronesia"                                   : @ "+691" ,
        @ "Moldova"                                       : @ "+373" ,
        @ "Monaco"                                       : @ "+377" ,
        @ "Mongolia"                                     : @ "+976" ,
        @ "Montenegro"                                   : @ "+382" ,
        @ "Montserrat"                                   : @ "+1664" ,
        @ "Morocco"                                       : @ "+212" ,
        @ "Myanmar"                                       : @ "+95" ,
        @ "Namibia"                                       : @ "+264" ,
        @ "Nauru"                                         : @ "+674" ,
        @ "Nepal"                                         : @ "+977" ,
        @ "Netherlands"                                   : @ "+31" ,
        @ "Netherlands Antilles"                         : @ "+599" ,
        @ "Nevis"                                         : @ "+1869" ,
        @ "New Caledonia"                                 : @ "+687" ,
        @ "New Zealand"                                   : @ "+64" ,
        @ "Nicaragua"                                     : @ "+505" ,
        @ "Message"                                         : @ "+227" ,
        @ "Nigeria"                                       : @ "+234" ,
        @ "Niue"                                         : @ "+683" ,
        @ "Norfolk Island"                               : @ "+672" ,
        @ "North Korea"                                   : @ "+850" ,
        @ "Northern Mariana Islands"                     : @ "+1670" ,
        @ "Norway"                                       : @ "+47" ,
        @ "Oman"                                         : @ "+968" ,
        @ "Pakistan"                                     : @ "+92" ,
        @ "Palau"                                         : @ "+680" ,
        @ "Palestinian Territory"                         : @ "+970" ,
        @ "Panama"                                       : @ "+507" ,
        @ "Papua New Guinea"                             : @ "+675" ,
        @ "Paraguay"                                     : @ "+595" ,
        @ "Peru"                                         : @ "+51" ,
        @ "Philippines"                                   : @ "+63" ,
        @ "Poland"                                       : @ "+48" ,
        @ "Portugal"                                     : @ "+351" ,
        @ "Puerto Rico"                                   : @ "+1787" ,
        @ "Puerto Rico"                                   : @ "+1939" ,
        @ "Qatar"                                         : @ "+974" ,
        @ "Reunion"                                       : @ "+262" ,
        @ "Romania"                                       : @ "+40" ,
        @ "Russia"                                       : @ "+7" ,
        @ "Rwanda"                                       : @ "+250" ,
        @ "Samoa"                                         : @ "+685" ,
        @ "San Marino"                                   : @ "+378" ,
        @ "Saudi Arabia"                                 : @ "+966" ,
        @ "Senegal"                                       : @ "+221" ,
        @ "Serbia"                                       : @ "+381" ,
        @ "Seychelles"                                   : @ "+248" ,
        @ "Sierra Leone"                                 : @ "+232" ,
        @ "Singapore"                                     : @ "+65" ,
        @ "Slovakia"                                     : @ "+421" ,
        @ "Slovenia"                                     : @ "+386" ,
        @ "Solomon Islands"                               : @ "+677" ,
        @ "South Africa"                                 : @ "+27" ,
        @ "South Georgia and the South Sandwich Islands" : @ "+500" ,
        @ "South Korea"                                   : @ "+82" ,
        @ "Spain"                                         : @ "+34" ,
        @ "Sri Lanka"                                     : @ "+94" ,
        @ "Sudan"                                         : @ "+249" ,
        @ "Suriname"                                     : @ "+597" ,
        @ "Swaziland"                                     : @ "+268" ,
        @ "Sweden"                                       : @ "+46" ,
        @ "Switzerland"                                   : @ "+41" ,
        @ "Syria "                                         : @"+963" ,
        @ "Taiwan"                                       : @ "+886" ,
        @ "Tajikistan"                                   : @ "+992" ,
        @ "Tanzania"                                     : @ "+255" ,
        @ "Thailand"                                     : @ "+66" ,
        @ "Timor Leste"                                   : @ "+670" ,
        @ "Togo"                                         : @ "+228" ,
        @ "Tokelau"                                       : @ "+690" ,
        @ "Tonga"                                         : @ "+676" ,
        @ "Trinidad and Tobago"                           : @ "+1868" ,
        @ "Tunisia"                                       : @ "+216" ,
        @ "Turkey"                                       : @ "+90" ,
        @ "Turkmenistan"                                 : @ "+993" ,
        @ "Turks and Caicos Islands"                     : @ "+1649" ,
        @ "Tuvalu"                                       : @ "+688" ,
        @ "Uganda"                                       : @ "+256" ,
        @ "Ukraine"                                       : @ "+380" ,
        @ "United Arab Emirates"                         : @ "+971" ,
        @ "United Kingdom"                               : @ "+44" ,
        @ "United States"                                 : @ "+1" ,
        @ "Uruguay"                                       : @ "+598" ,
        @ "US Virgin Islands"                           : @ "+1340" ,
        @ "Uzbekistan"                                   : @ "+998" ,
        @ "Vanuatu"                                       : @ "+678" ,
        @ "Venezuela"                                     : @ "+58" ,
        @ "Vietnam"                                       : @ "+84" ,
        @ "Wake Island"                                   : @ "+1808" ,
        @ "Wallis and Futuna"                             : @ "+681" ,
        @ "Yemen"                                         : @ "+967" ,
        @ "Zambia"                                       : @ "+260" ,
        @ "Zanzibar"                                     : @ "+255" ,
        @ "Zimbabwe"                                     : @ "+263"
    } ;
    return dialingCodes;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
