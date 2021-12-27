% Fetch list of tickers to retrieve close data from
T = readtable('portfolio.txt');


% TODO: Initial date must be dynamically selected (such as by taking the
% latest available date
initDate = '1-Jan-2014';

tickers = T.tickers;

% TODO: Stop changing the size of the results array all the time
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