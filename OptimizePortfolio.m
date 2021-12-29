% Read allocations from the table
T = readtable('Portfolio.xlsx');

% Load Parameters
tickers = T.Tickers;
original_weights = T.Weights;

% Read market data file previously generated
% TODO: If there is no market data it or there is that option it should
% re-fetch it, otherwise no need to keep running the function over and 
% over again...
RetrieveMarketData
market_data = readtimetable('market_data.csv');
dates = market_data.Time;

% Obtain daily returns
daily_return = tick2ret(market_data{:, 1:end});

% Construct Portfolio
p = Portfolio('AssetList', tickers);

% Estimate Portfolio Moments
p = estimateAssetMoments(p, daily_return);

% Set Portfolio Constraints, Long Only, 100% allocation at all times
p = setDefaultConstraints(p);

% Estimate Optimal Weights for Sharpe Ratio
% TODO: You should be able to select what you wish to optimize for 
optimal_weights = estimateMaxSharpeRatio(p);

% Calculate moments. Not sure what is wrong with these though....
% [risk_original, ret_original] = estimatePortMoments(p, original_weights);
% [risk_optimal, ret_optimal] = estimatePortMoments(p, optimal_weights);
% 
% sharpe_original = estimatePortMoments(p, original_weights);
% sharpe_optimal = estimatePortMoments(p, optimal_weights);

% Portfolio returns & Price
portfolio_returns_original = daily_return * original_weights;
portfolio_returns_optimal  = daily_return * optimal_weights;

% Integrate to calculate price of each portfolio
portfolio_value_original = 1e4 * exp(cumsum([0; portfolio_returns_original]));
portfolio_value_optimal  = 1e4 * exp(cumsum([0; portfolio_returns_optimal]));


portfolio_returns_tt = timetable(dates(2:end), portfolio_returns_original, portfolio_returns_optimal);

% Visualizations: 
% Pie and chart of the original portfolio
fig1 = figure('Name', 'Portfolio Allocations', 'NumberTitle', 'off');
t = tiledlayout(1, 2, 'TileSpacing', 'compact');

% Create pie charts
ax1 = nexttile;
pie(ax1, original_weights);
hold on

title('Provided Portfolio');

ax2 = nexttile;
pie(ax2, optimal_weights);
title('Max Sharpe Portfolio');

lgd = legend(tickers);
hold off


% Portfolio prices
fig2 = figure('Name', 'Portfolio Prices', 'NumberTitle', 'off');
t = tiledlayout(1, 1);
semilogy(dates, portfolio_value_original,'DisplayName','Original Portfolio')
hold on
semilogy(dates, portfolio_value_optimal,'DisplayName','Optimal Portfolio')
xlabel("Date");
ylabel("Portfolio Value");
legend({'Original Portfolio' 'Optimal Portfolio'});
hold off


% Security specific information
t = table(tickers, original_weights, optimal_weights);
fig3 = uifigure('Name', 'Securities Data', 'NumberTitle', 'off');
uit = uitable(fig3,'Data',t);


% Portfolio specific charts
% Calculations
annualized_portfolio_returns = retime(portfolio_returns_tt, "yearly","sum");

% TODO: We shouldn't assume that the risk-less rate is zero
annualized_sharpe_original = sqrt(252) * sharpe(portfolio_returns_original, 0);
annualized_sharpe_optimal  = sqrt(252) * sharpe(portfolio_returns_optimal, 0);

% Outputs 
start_balance = [portfolio_value_original(1) portfolio_value_optimal(1)];
end_balance = [portfolio_value_original(end) portfolio_value_optimal(end)];
annualized_return = [mean(annualized_portfolio_returns.portfolio_returns_original) mean(annualized_portfolio_returns.portfolio_returns_optimal)];
standard_deviation = [std(annualized_portfolio_returns.portfolio_returns_original) std(annualized_portfolio_returns.portfolio_returns_optimal)];
best_year = [max(annualized_portfolio_returns.portfolio_returns_original) max(annualized_portfolio_returns.portfolio_returns_optimal)];
worst_year = [min(annualized_portfolio_returns.portfolio_returns_original) min(annualized_portfolio_returns.portfolio_returns_optimal)];
max_drawdown = [maxdrawdown(portfolio_value_original) maxdrawdown(portfolio_value_optimal)];
sharpe_ratio = [annualized_sharpe_original annualized_sharpe_optimal];

% Final Table 
data = [start_balance; end_balance; annualized_return; standard_deviation; 
    best_year; worst_year; max_drawdown; sharpe_ratio];

results = array2table(data, 'VariableNames', {'Provided Portfolio', 'Optimal Portfolio'}, ...
    'RowNames', {'Start Balance', 'End Balance', 'CAGR', 'Standard Deviation', 'Best Year' ...
    'Worst Year', 'Max Drawdown', 'Sharpe Ratio'});

fig4 = uifigure('Name', 'Portfolio Data', 'NumberTitle', 'off');
uit = uitable(fig4,'Data',results);

% Save figures to use with the report
savefig(fig1, 'Figures/fig1');
savefig(fig2, 'Figures/fig2');
savefig(fig3, 'Figures/fig3');
savefig(fig4, 'Figures/fig4');