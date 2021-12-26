% Fetch list of tickers to retrieve close data from
fileID = fopen('tickers.txt','r');

% TODO: Initial date must be dynamically selected (such as by taking the
% latest available date
initDate = '1-Jan-2014';
A = fscanf(fileID, "%s");
tickers = strsplit(A, ",");
results = {};

% Iterate through every ticker and append it to the results list
for tckr = tickers
    history = getMarketDataViaYahoo(tckr{1}, initDate);    
    history_price = timeseries(history.Close, datestr(history(:,1).Date), 'Name', tckr{1});
    results = [results history_price];
end

% Construct a timetable from all the timeseries
tt = timeseries2timetable(results);

% Write timetable contents into a csv that can be used afterwards 
writetimetable(tt, "market_data.csv")