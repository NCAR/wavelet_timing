
fig_supp_table = 'figure'
figure_number = '06'
tag = ''
location = 'taylor_river'
time_period = 'one_year'
source('mk_file_name.R')

data = WtGetEventData(location, time_period)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list('NWM v1.2'=data$`NWM v1.2`),
  min_ts_length=72,
  max.scale=256,
  rm_chunks_warn=FALSE
)

figure = step1_figure(wt_event)
ggsave(file=figure_name, figure)
