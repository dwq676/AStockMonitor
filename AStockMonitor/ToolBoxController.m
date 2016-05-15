//
//  ToolBoxController.m
//  AStockMonitor
//
//  Created by __huji on 15/1/2016.
//  Copyright © 2016 huji. All rights reserved.
//

#import "ToolBoxController.h"
#import "StocksManager.h"
#import "GetStockRequest.h"
#import "ASConfig.h"

@interface ToolBoxController () <NSTextFieldDelegate>
@property (strong) NSView *contentView;
@property (strong) NSButton *addButton;
@property (strong) NSTextField *codeField;

@property (strong) NSView *lastAddButton;
@end

@implementation ToolBoxController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentView = [[NSView alloc] init];

        [self addButton:@"chat" action:@selector(chatClick) size:14];
        
        self.addButton = [self addButton:@"add" action:@selector(addStock) size:12];
        self.addButton.tag = 0;
        
    }
    return self;
}

-(NSButton*)addButton:(NSString*)imageName action:(SEL)action size:(CGFloat)size{
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
    img.size = NSMakeSize(size, size);
    NSButton *button = [[NSButton alloc] init];
    [button setImage:img];
    [button  setTarget:self];
    [button setAction:action];
    button.bordered = NO;
    [self.contentView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lastAddButton?self.lastAddButton.mas_right:self.contentView.mas_left).offset(2);
        make.top.equalTo(self.contentView);
        if ([imageName isEqualToString:@"add"]) {
            make.width.equalTo(self.contentView.mas_width).offset(-14);
        }else{
            make.width.equalTo(@(img.size.width));
        }
        make.height.equalTo(@(TOOLBOXHEI));
    }];
    
    
    self.lastAddButton = button;
    return button;
}

-(void)chatClick{
    LHS(@"chat");
    
    NSString *url = [ASConfig as_chat_url];
    if (url) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}

-(NSView *)view{
    return self.contentView;
}
-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector{
    if (commandSelector == @selector(insertNewline:)) {
        NSString *code = textView.string;
        if (code.length == 6){
            [self valideStock:code];
        }else{
            [self error:[NSString stringWithFormat:@"股票代码错误,%@",code]];
        }
        
        return YES;
    }
    return NO;
}

-(void)valideStock:(NSString*)code{
   [self valideAndAddStock:code sz:[NSString stringWithFormat:@"sz%@",code] sh:[NSString stringWithFormat:@"sh%@",code]];
}

-(void)valideAndAddStock:(NSString*)ori sz:(NSString*)sz sh:(NSString*)sh{
    self.addButton.enabled = NO;
    self.codeField.editable = NO;
    [self.window makeFirstResponder:nil];
    
    GetStockRequest *req = [[GetStockRequest alloc] init];
    [req requestForStocks:@[sh,sz] block:^(NSArray *stocks) {
        if (stocks) {
            if (stocks.count>0) {
                for (NSDictionary *info in stocks) {
                     [[StocksManager manager] addStocks:@[info[@"股票代码"]]];
                }
                [self cleanup];
            }else{
                [self error:[NSString stringWithFormat:@"股票代码有误,%@",ori]];
            }
        }else{
            [self error:@"网络错误，请重试"];
        }
        
        self.addButton.enabled = YES;
        self.codeField.editable = YES;
    }];
}

-(void)error:(NSString*)err{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = err;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
    
    LHS(err);
}

-(void)addStock{
    if (self.addButton.tag == 0) {
        LHS(@"showaddstock");
        
        NSImage *closeimg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"close" ofType:@"png"]];
        [self.addButton setImage:closeimg];
        self.addButton.tag = 1;
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(TOOLBOXHEI + TOOLBOXEDITHEI));
        }];
        
        NSTextField *field = [[NSTextField alloc] init];
        field.editable = YES;
        field.selectable = YES;
        field.placeholderString = @"股票代码+回车";
        field.delegate = self;
        [self.contentView addSubview:field];
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.top.equalTo(self.addButton.mas_bottom);
            make.right.equalTo(self.contentView.mas_right);
            make.height.equalTo(@(TOOLBOXEDITHEI));
        }];
        [self.window makeFirstResponder:field];
        self.codeField = field;
        
        [self.delegate didRefresh];
    }else{
        LHS(@"closeadd");
        
        [self cleanup];
    }
}

-(void)cleanup{
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(TOOLBOXHEI));
    }];
    [self.codeField removeFromSuperview];
    self.codeField = nil;
    
    NSImage *addimg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add" ofType:@"png"]];
    [self.addButton setImage:addimg];
    self.addButton.tag = 0;
    
    [self.delegate didRefresh];
}

@end
