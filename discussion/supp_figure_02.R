
fig_supp_table = 'supp_figure'
figure_number = '02'
tag = ''
location = 'onion_creek'
time_period = 'one_event'
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

figure <- step2_figure(wt_event)
ggsave(file=figure_name, figure)
