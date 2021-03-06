
fig_supp_table = 'figure'
figure_number = '05'
tag = ''
location <- 'pemigewasset_river'
time_period <- 'small_event'
source('mk_file_name.R')

data = WtGetEventData(location, time_period)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list('NWM v1.2'=data$`NWM v1.2`),
  min_ts_length=24,
  max.scale=256,
  rm_chunks_warn=FALSE
)

figure <- event_cluster_timing_by_period(wt_event, n_period=5)
ggsave(file=figure_name, figure)
