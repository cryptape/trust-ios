//
//  ViewController.m
//  BLEPurseSDK_demo
//
//  Created by yang on 2018/10/19.
//  Copyright © 2018年 com.bluering. All rights reserved.
//

#import "ViewController.h"
#import <BLEPurseSDK/BLEPurseSDK.h>

@interface ViewController ()<CBCentralManagerDelegate ,UITableViewDelegate, UITableViewDataSource>{
    CBCentralManager *_manager;
    CBPeripheral *_peripheral;
    
    UITableView *_tableView;
    NSMutableArray *dataArr;
    
    NSMutableSet *_peripheralSet;
    
    UITextView *_textView;
    UITextField *_pinTextField;
    UITextField *_pukTextField;
    BOOL flag;
}

@property (nonatomic, copy) NSString *logString;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _peripheralSet = [NSMutableSet set];
    flag = NO;
    //初始化SDK
    [BLEPurseSDK initWithEncKey:@"7404BE01D1C52CDD0DEA7BFAD37B5CD8"
                     withMacKey:@"121C29F27546F9DCF25E3AB7C116EA61"
                     withDecKey:@"7377C0D7F2F3A6561FABFD13DFC5E501"];
    [self createView];
}



- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            // 开始扫描周围的外设。
            /*
             -- 两个参数为Nil表示默认扫描所有可见蓝牙设备。
             -- 注意：第一个参数是用来扫描有指定服务的外设。然后有些外设的服务是相同的，比如都有FFF5服务，那么都会发现；而有些外设的服务是不可见的，就会扫描不到设备。
             -- 成功扫描到外设后调用didDiscoverPeripheral
             */
            [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey :@YES}];//@{CBCentralManagerScanOptionAllowDuplicatesKey :@YES}
        }
            break;
        default:
            break;
    }
}

#pragma mark 发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *locolName = [[advertisementData objectForKey:@"kCBAdvDataLocalName"] lowercaseString];
    //    NSString *peripheralName = [peripheral.name lowercaseString];
    //    NSLog(@"locolName:%@\nperipheralName:%@", locolName,peripheralName);
    if (locolName) {
        NSInteger peripheralNum = _peripheralSet.count;
        [_peripheralSet addObject:peripheral];
        if (peripheralNum != _peripheralSet.count) {
            //刷新
            dataArr = [NSMutableArray arrayWithArray:[_peripheralSet allObjects]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_tableView reloadData];
            });
        }
    }
}

- (void)configBLEPurseSDK{
    if (!_manager) {
        return;
    }
    if (!_peripheral) {
        return;
    }
    flag = [[BLEPurseSDK shareInstance] connectPeripheral:_manager withCBPeripheral:_peripheral];
    
    if (flag == YES) {
        NSLog(@"蓝牙连接成功");
        self.logString = [self.logString stringByAppendingString:@"蓝牙连接成功\n"];
    }else {
        NSLog(@"蓝牙连接失败");
        self.logString = [self.logString stringByAppendingString:@"蓝牙连接失败\n"];
    }
}

- (void)createView{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(self.view.frame.size.width / 2 - 140, 30, 120, 30);
    [searchBtn setTitle:@"搜索蓝牙" forState:UIControlStateNormal];
    searchBtn.backgroundColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
    [searchBtn addTarget:self action:@selector(btn_action:) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:searchBtn];
    
    UIButton *connetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connetBtn.frame = CGRectMake(self.view.frame.size.width / 2 + 20, 30, 120, 30);
    [connetBtn setTitle:@"连接蓝牙" forState:UIControlStateNormal];
    connetBtn.backgroundColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
    [connetBtn addTarget:self action:@selector(btn_action:) forControlEvents:UIControlEventTouchUpInside];
    connetBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:connetBtn];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [searchBtn addSubview:self.activityIndicator];
    //设置小菊花的frame
    self.activityIndicator.frame= CGRectMake(6, 7, 16, 16);
    //设置小菊花颜色
    self.activityIndicator.color = [UIColor redColor];
    //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
    self.activityIndicator.hidesWhenStopped = YES;
    
    
    NSArray *array = @[@"获取ID",@"校验PIN",@"修改PIN",@"生成秘钥",@"重置秘钥",@"导入秘钥",@"读取公钥",@"数字签名",@"解锁PIN"];
    CGFloat width = (self.view.frame.size.width - 75) / 4;
    for (int i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(15 + (width + 15) * (i % 4), 80 + 40 * (i / 4), width, 30);
        [btn setTitle:array[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
        [btn addTarget:self action:@selector(btn_action:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.view addSubview:btn];
    }
    
    _pinTextField = [[UITextField alloc]initWithFrame:CGRectMake(30, 210, self.view.frame.size.width - 60, 40)];
    _pinTextField.backgroundColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
    _pinTextField.placeholder = @"请输入PIN码";
    [self.view addSubview:_pinTextField];
    
    _pukTextField = [[UITextField alloc]initWithFrame:CGRectMake(30, 260, self.view.frame.size.width - 60, 40)];
    _pukTextField.backgroundColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
    _pukTextField.placeholder = @"请输入PUK码";
    [self.view addSubview:_pukTextField];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(30, 310, self.view.frame.size.width - 60, self.view.frame.size.height - 310 - (self.view.frame.size.width - 120))];
    _textView.backgroundColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
    //    _textView.userInteractionEnabled = NO;
    _textView.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_textView];
    
    self.logString = [NSString string];
    
    dataArr = [NSMutableArray array];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 450, self.view.frame.size.width, self.view.frame.size.height - 450) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
}

- (void)setLogString:(NSString *)logString{
    _logString = logString;
    _textView.text = _logString;
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:13]};
    CGRect rect = [_textView.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil];
    if (rect.size.height > _textView.frame.size.height) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_textView.contentOffset = CGPointMake(0, rect.size.height - self->_textView.frame.size.height);
        }];
    }
}

- (void)btn_action:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"搜索蓝牙"]) {
        if (!_manager) {
            dispatch_queue_t concurrentQueue = dispatch_queue_create("com.ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
            _manager = [[CBCentralManager alloc] initWithDelegate:self queue:concurrentQueue];
            [self.activityIndicator startAnimating];
            self.logString = [self.logString stringByAppendingString:@"开始搜索蓝牙\n"];
        }
    }else if ([btn.titleLabel.text isEqualToString:@"连接蓝牙"]) {
        if (_peripheral == nil) {
            NSLog(@"请先选择外部设备");
            self.logString = [self.logString stringByAppendingString:@"请先选择外部设备\n"];
            return;
        }
        [self configBLEPurseSDK];
    }else if ([btn.titleLabel.text isEqualToString:@"获取ID"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        NSString *result = [BLEPurseSDK getID];
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"获取到的蓝牙ID：%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"校验PIN"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        if (_pinTextField.text.length == 0) {
            self.logString = [self.logString stringByAppendingString:@"请先输入PIN码\n"];
            return;
        }
        NSString *result = [NSString stringWithFormat:@"%ld",[BLEPurseSDK verifyPIN:_pinTextField.text]];
        if ([result isEqualToString:@"36864"]) {
            result = @"校验PIN成功";
        }else {
            result = [@"校验PIN失败：" stringByAppendingString:result];
        }
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"修改PIN"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        if (_pinTextField.text.length == 0) {
            self.logString = [self.logString stringByAppendingString:@"请先输入PIN码\n"];
            return;
        }
        NSString *result = [NSString stringWithFormat:@"%ld",[BLEPurseSDK changePIN:_pinTextField.text]];
        if ([result isEqualToString:@"36864"]) {
            result = @"修改PIN成功";
        }else {
            result = [@"修改PIN失败：" stringByAppendingString:result];
        }
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"生成秘钥"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        NSString *result = [NSString stringWithFormat:@"%ld",[BLEPurseSDK generateKey]];
        if ([result isEqualToString:@"36864"]) {
            result = @"生成秘钥成功";
        }else {
            result = [@"生成秘钥失败：" stringByAppendingString:result];
        }
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"重置秘钥"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        NSString *result = [NSString stringWithFormat:@"%ld",[BLEPurseSDK resetKey]];
        if ([result isEqualToString:@"36864"]) {
            result = @"重置秘钥成功";
        }else {
            result = [@"重置秘钥失败：" stringByAppendingString:result];
        }
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"导入秘钥"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        NSString *result = [NSString stringWithFormat:@"%ld",[BLEPurseSDK importprivateKey:@"64B882370C4A3E881C3BA8D1C2A59F568078EEA33251814C426D82490CD704CA" publicKey:nil]];
        if ([result isEqualToString:@"36864"]) {
            result = @"导入秘钥成功";
        }else {
            result = [@"导入秘钥失败：" stringByAppendingString:result];
        }
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"读取公钥"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        NSString *result = [BLEPurseSDK getPublicKey];
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"读取公钥结果：%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"数字签名"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        NSString *result = [BLEPurseSDK sign:@"BBF4F6F1171365E5C0CEAA3C5DC86DDC4936ADAD1BCBAF38672E568554A8485D"];
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"数字签名结果：%@\n",result]];
    }else if ([btn.titleLabel.text isEqualToString:@"解锁PIN"]) {
        if (flag == NO) {
            self.logString = [self.logString stringByAppendingString:@"请先连接蓝牙\n"];
            return;
        }
        if (_pinTextField.text.length == 0) {
            self.logString = [self.logString stringByAppendingString:@"请先输入PIN码\n"];
            return;
        }
        if (_pukTextField.text.length == 0) {
            self.logString = [self.logString stringByAppendingString:@"请先输入PUK码\n"];
            return;
        }
        NSInteger a = [BLEPurseSDK unblockPIN:_pinTextField.text withPUK:_pukTextField.text];
        NSString *result = [NSString stringWithFormat:@"%ld",a];
        if ([result isEqualToString:@"36864"]) {
            result = @"解锁PIN成功";
        }else {
            result = [@"解锁PIN失败：" stringByAppendingString:result];
        }
        self.logString = [self.logString stringByAppendingString:[NSString stringWithFormat:@"解锁PIN结果：%@\n",result]];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    CBPeripheral *per = dataArr[indexPath.row];
    cell.textLabel.text = [per.name lowercaseString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *per = dataArr[indexPath.row];
    _peripheral = per;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
