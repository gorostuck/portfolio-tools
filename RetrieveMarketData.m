% Fetch list of tickers to retrieve close data from
T = readtable('Portfolio.xlsx');


% Load Parameters
% TODO: We should test that the earliest available date is later than the 
% backtesting starting date written by the user
initDate = T.StartDate(1);
tickers = T.Tickers;

% Add path of Financial Data files
addpath('FinancialData')


% TODO: Stop changing the size of the results array all the time and 
% instead create a matrix that is filled up
results = {};

% Iterate through every ticker and append it to the results list
for k=1:length(tickers)
    current_ticker = tickers(k);
    current_ticker = current_ticker{1};
    history = getMarketDataViaYahoo(current_ticker, initDate);    
    history_price = timeseries(history.Close, datestr(history(:,1).Date), 'Name', current_ticker);
    results = [results history_price];
end

% Construct a timetable from all the timeseries
tt = timeseries2timetable(results);

% Write timetable contents into a csv that can be used afterwards 
writetimetable(tt, "market_data.csv")