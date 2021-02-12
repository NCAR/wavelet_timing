library(rwrfhydro)
library(data.table)
library(htmlTable)
library(magrittr)
library(plyr)

options(warn=1)

location = 'taylor_river'
time_period = 'five_years'

data = WtGetEventData(location, time_period)

wt_event = WtEventTiming(
    POSIXct=data$POSIXct,
    obs=data$q_cms_obs,
    mod=list(
        'NWM v1.0'=data$`NWM v1.0`,
        'NWM v1.1'=data$`NWM v1.1`,
        'NWM v1.2'=data$`NWM v1.2`
    ),
    min_ts_length=256,
    max.scale=256
)

we_stats = we_hydro_stats(wt_event)
max_stats = data.table(ldply(
    we_stats[ names(we_stats)[-length(we_stats)] ],
    function(ll) ll$xwt$event_timing$cluster_max))

tavg_cols = c('period', 'obs_power_corr')
tavg_stats = we_stats$`NWM v1.2`$xwt$event_timing$time_avg[, ..tavg_cols]

max_stats = merge(max_stats, tavg_stats, by='period', suffix=c('_max', '_tavg'))

max_stats = max_stats[order(-obs_power_corr_tavg, .id)]
max_stats[, n_clusters:=.N, by=c('.id','period')]

misses_to_na = function(hitmiss, value) ifelse(hitmiss, value, NA)
max_stats[, time_err_2:=misses_to_na(xwt_signif, time_err)]
max_stats[, median_time_err:=median(time_err_2, na.rm=TRUE), by=c('.id','period')]

max_stats[, pct_hits:=length(which(!is.na(time_err_2)))/.N * 100, by=c('.id', 'period')]

max_stats = max_stats[, .SD[1], by=c('.id','period')]

cols = c('.id', 'period', 'obs_power_corr_tavg', 'n_clusters',
         'pct_hits', 'median_time_err')
new_cols = c('NWM Version', 'Characteristic Timescale (hr)', 'Avg WT Power', 'Number of Clusters',
             '% Hits',  'Median Timing Error (hr)')
the_table = head(setnames(setcolorder(max_stats[, ..cols], cols), cols, new_cols), 9)
the_table %>% htmlTable(rnames=FALSE)
