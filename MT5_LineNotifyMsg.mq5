//+------------------------------------------------------------------+
//|                                                LineNotifyMsg.mq5 |
//|                                                    Copyright CCW |
//|      https://tw.tradingview.com/pricing/?share_your_love=CCWxUmi |
//+------------------------------------------------------------------+
#property copyright "CCW"
#property link      "https://tw.tradingview.com/pricing/?share_your_love=CCWxUmi"

// Line Notify Token
input string LineNotifyToken = "your_token";

// 初始化函數
int OnInit()
  {
   Print("Expert Advisor initialized");
   return(INIT_SUCCEEDED);
  }

// 去初始化函數
void OnDeinit(const int reason)
  {
   Print("Expert Advisor deinitialized");
  }

// 交易事件函數
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
  {
   // 檢查交易類型
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong deal_ticket = trans.deal;
      double deal_price = trans.price;
      double deal_volume = trans.volume;
      string deal_symbol = trans.symbol;
      int deal_type = trans.deal_type;

      string message;
      if(deal_type == DEAL_TYPE_BUY)
        {
         message = "\nSymbol: " + deal_symbol + "\nOrder: Buy" + "\nPrice: " + DoubleToString(deal_price, 4) + "\nVolume: " + DoubleToString(deal_volume, 2) ;
        }
      else if(deal_type == DEAL_TYPE_SELL)
        {
         message = "\nSymbol: " + deal_symbol + "\nOrder: Sell" + "\nPrice: " + DoubleToString(deal_price, 4) + "\nVolume: " + DoubleToString(deal_volume, 2) ;
        }

      // 發送 Line Notify
      if(message != "")
        {
         SendLineNotify(message);
        }
     }
  }

// 發送 Line Notify 的函數
void SendLineNotify(string message)
  {
   string url = "https://notify-api.line.me/api/notify"; // put this url to MT4/MT5 Allow webrequest listed url
   string headers = "Content-Type: application/x-www-form-urlencoded\r\nAuthorization: Bearer " + LineNotifyToken;
   string data = "message=" + message;
   
   char post_data[];
   StringToCharArray(data, post_data);

   char result[];
   string response_headers;

   int res = WebRequest("POST", url, headers, 5, post_data, result, response_headers);
   
   if(res == -1)
     {
      Print("Error in WebRequest. Error Code: ", GetLastError());
     }
   else
     {
      string response = CharArrayToString(result);
      Print("Line Notify Response: ", response);
     }
  }
//+------------------------------------------------------------------+


