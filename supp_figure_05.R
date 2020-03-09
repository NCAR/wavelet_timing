
fig_supp_table = 'supp_figure'
figure_number = '05'
tag = ''
location = 'taylor_river'
time_period = 'five_years'
source('mk_file_name.R')

data <- WtGetEventData(location, time_period)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list(
    'NWM v1.0'=data$`NWM v1.0`,
    'NWM v1.1'=data$`NWM v1.1`,
    'NWM v1.2'=data$`NWM v1.2`),
  min_ts_length=456,
  max.scale=256,
  rm_chunks_warn=FALSE)

we_stats <- we_hydro_stats(wt_event)

figure <- event_cluster_timing_summary_by_period(
    we_stats,
    wt_event=wt_event,
    n_period=2, 
    distiller_pal='RdYlBu', 
    timing_stat='cluster_max',
    signif_threshold=NULL
)$ggplot

ggsave(file=figure_name, figure)
