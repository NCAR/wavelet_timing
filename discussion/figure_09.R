# options(warn=0)

fig_supp_table = 'figure'
figure_number = '09'
tag = ''
location = 'taylor_river'
time_period = 'one_season'
source('mk_file_name.R')

data <- WtGetEventData(location, time_period)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list('NWM v1.2'=data$`NWM v1.2`),
  min_ts_length=48,
  max.scale=256,
  rm_chunks_warn=FALSE
)

## figure1 <- step1_figure(wt_event)
## library(grid)
## grid.draw(figure1)

## figure2 <- step2_figure(wt_event)
## grid.draw(figure2)

figure <- event_cluster_timing_by_period(wt_event, n_period=1)
ggsave(file=figure_name, figure)
