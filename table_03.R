library(rwrfhydro)
library(data.table)
library(htmlTable)
library(magrittr)
location = 'pemigewasset_river'
time_period = 'small_event'

data = WtGetEventData(location, time_period)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list('NWM v1.2'=data$`NWM v1.2`),
  min_ts_length=24,
  max.scale=256,
  rm_chunks_warn=FALSE
)

we_stats = we_hydro_stats(wt_event)
max_stats = we_stats$`NWM v1.2`$xwt$event_timing$cluster_max

tavg_cols = c('period', 'obs_power_corr')
tavg_stats = we_stats$`NWM v1.2`$xwt$event_timing$time_avg[, ..tavg_cols]

max_stats = merge(max_stats, tavg_stats, by='period', suffix=c('_max', '_tavg'))

max_stats = max_stats[order(-obs_power_corr_tavg)]
max_stats[, n_clusters:=.N, by='period']
misses_to_na = function(hitmiss, value) ifelse(hitmiss, value, NA)
max_stats[, time_err_2:=misses_to_na(xwt_signif, time_err)]
max_stats[, avg_time_err:=mean(time_err_2, na.rm=TRUE), by='period']
max_stats[, pct_hits:=length(which(!is.na(time_err_2)))/.N * 100, by='period']

cols = c('period', 'obs_power_corr_tavg', 'period_clusters', 'time_err_2',
         'xwt_signif', 'n_clusters', 'pct_hits', 'avg_time_err')
new_cols = c('Characteristic Timescale (hr)', 'Avg WT Power', 'Cluster', 'Timing Error (hr)',
             'Hit?', 'Total Number of Clusters', '% Hits', 'Avg Timing Error (hr)')
the_table = head(setnames(setcolorder(max_stats[, ..cols], cols), cols, new_cols), 12)
the_table %>% htmlTable(rnames=FALSE)
