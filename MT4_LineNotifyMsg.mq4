//+------------------------------------------------------------------+
//|                                                LineNotifyMsg.mq4 |
//|                                                    Copyright CCW |
//|      https://tw.tradingview.com/pricing/?share_your_love=CCWxUmi |
//+------------------------------------------------------------------+
#property copyright "CCW"
#property link      "https://tw.tradingview.com/pricing/?share_your_love=CCWxUmi"

// Line Notify Token
extern string LineNotifyToken = "your_token";

// 静态变量来记录最后处理的订单时间
datetime lastTradeTime = 0;

// 初始化函数
int OnInit()
  {
   Print("Expert Advisor initialized");

   // 初始化时设置最后处理的订单时间为最新的订单时间，避免处理历史订单
   int total = OrdersHistoryTotal();
   if(total > 0)
     {
      if(OrderSelect(total - 1, SELECT_BY_POS, MODE_HISTORY))
        {
         lastTradeTime = OrderCloseTime();
        }
     }

   return(INIT_SUCCEEDED);
  }

// 去初始化函数
void OnDeinit(const int reason)
  {
   Print("Expert Advisor deinitialized");
}

// 交易事件函数
void OnTick()
  {
   // 处理当前打开的订单
   int totalOpenOrders = OrdersTotal();
   for(int i = 0; i < totalOpenOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderOpenTime() > lastTradeTime)
           {
            string message;
            if(OrderType() == OP_BUY)
              {
               message = "\nSymbol: " + OrderSymbol() + "\nOrder: Buy" + "\nPrice: " + DoubleToString(OrderOpenPrice(), 4) + "\nVolume: " + DoubleToString(OrderLots(), 2);
              }
            else if(OrderType() == OP_SELL)
              {
               message = "\nSymbol: " + OrderSymbol() + "\nOrder: Sell" + "\nPrice: " + DoubleToString(OrderOpenPrice(), 4) + "\nVolume: " + DoubleToString(OrderLots(), 2);
              }

            // 发通知
            if(message != "")
              {
               Print("Sending Line Notify message: ", message);  // 日志输出消息
               SendLineNotify(message);
              }

            // 更新最后处理的订单时间
            lastTradeTime = OrderOpenTime();
           }
        }
      else
        {
         Print("OrderSelect failed for index ", i, " with error #", GetLastError());
        }
     }

   // 处理历史订单
   int totalHistoryOrders = OrdersHistoryTotal();
   for(int i = 0; i < totalHistoryOrders; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderCloseTime() > lastTradeTime)
           {
            string message;
            if(OrderType() == OP_BUY)
              {
               message = "\nSymbol: " + OrderSymbol() + "\nOrder: Buy Closed" + "\nPrice: " + DoubleToString(OrderClosePrice(), 4) + "\nVolume: " + DoubleToString(OrderLots(), 2);
              }
            else if(OrderType() == OP_SELL)
              {
               message = "\nSymbol: " + OrderSymbol() + "\nOrder: Sell Closed" + "\nPrice: " + DoubleToString(OrderClosePrice(), 4) + "\nVolume: " + DoubleToString(OrderLots(), 2);
              }

            // 发通知
            if(message != "")
              {
               Print("Sending Line Notify message: ", message);  // 日志输出消息
               SendLineNotify(message);
              }

            // 更新最后处理的订单时间
            lastTradeTime = OrderCloseTime();
           }
        }
      else
        {
         Print("OrderSelect failed for index ", i, " with error #", GetLastError());
        }
     }
  }

// 发送 Line Notify 的函数
void SendLineNotify(string message)
  {
   string url = "https://notify-api.line.me/api/notify";
   string headers = "Content-Type: application/x-www-form-urlencoded\r\nAuthorization: Bearer " + LineNotifyToken;
   string data = "message=" + message;
   
   char post_data[];
   StringToCharArray(data, post_data);

   char result[];
   string response_headers;

   int res = WebRequest("POST", url, headers, 0, post_data, result, response_headers);
   
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
