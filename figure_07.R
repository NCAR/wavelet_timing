library(rwrfhydro)
options(warn=1)

fig_supp_table = 'figure'
figure_number = '07'
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

figure = step2_figure(wt_event, ylab_spacer=.08)
ggsave(file=figure_name, figure, height=7, width=7)
