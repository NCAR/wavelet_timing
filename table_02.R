library(rwrfhydro)
library(data.table)
##library(htmlTable)
library(expss)
library(magrittr)
options(warn=1)

location = 'onion_creek'
time_period = 'one_event'

data = WtGetEventData(location, time_period)

offsetIt = 5 # hours
offstart = rep(NA, times = offsetIt)
pairStart = 1
pairEnd   = dim(data)[1] - offsetIt
offend = data$q_cms_obs[pairStart:pairEnd]
data$q_cms_obs_off = c(offstart, offend)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list('Synthetic'=data$`q_cms_obs_off`),
  min_ts_length=24,
  max.scale=256,
  rm_chunks_warn=FALSE
)

we_stats = we_hydro_stats(wt_event)
max_stats = we_stats$Synthetic$xwt$event_timing$cluster_max

tavg_cols = c('period', 'obs_power_corr')
tavg_stats = we_stats$Synthetic$xwt$event_timing$time_avg[, ..tavg_cols]

max_stats = merge(max_stats, tavg_stats, by='period', suffix=c('_max', '_tavg'))

cols = c('period', 'obs_power_corr_tavg', 'period_clusters', 'time_err', 'time', 'xwt_signif')
new_cols = c('Characteristic Timescale (hr)', 'Avg WT Power', 'Number of Clusters', 'Timing Error (hr)',
             'Time (hr)', 'Hit')
the_table = setnames(
    setcolorder(max_stats[, ..cols], cols),
    cols, new_cols)
output_table = the_table %>% htmlTable(rnames=FALSE)

