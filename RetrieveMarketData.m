function RetrieveMarketData(initDate, tickers)

% Fetch list of tickers to retrieve close data from
%T = readtable('Portfolio.xlsx');


% Load Parameters
% TODO: We should test that the earliest available date is later than the 
% backtesting starting date written by the user
if nargin < 1
    initDate = T.StartDate(1);
end
%tickers = T.Tickers;

% Add path of Financial Data files
addpath('FinancialData')


% First load market data and use it to synchronize the rest of the tickers 
% against it
market_ticker = 'SPY';
market_history = getMarketDataViaYahoo(market_ticker, initDate);
history_price_market = timeseries(market_history.Close, datestr(market_history(:,1).Date), 'Name', market_ticker);
tt = timeseries2timetable(history_price_market);


% instead create a matrix that is filled up
results = {};

% Iterate through every ticker and append it to the results list
for k=1:length(tickers)
    current_ticker = tickers(k);
    current_ticker = current_ticker{1};
    history = getMarketDataViaYahoo(current_ticker, initDate);    
    history_price = timeseries(history.Close, datestr(history(:,1).Date), 'Name', current_ticker);
    new_ticker_tt = timeseries2timetable(history_price);
    tt = synchronize(tt, new_ticker_tt);
end

% Write timetable contents into a csv that can be used afterwards 
writetimetable(tt, "market_data.csv")