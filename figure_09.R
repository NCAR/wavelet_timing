library(rwrfhydro)
library(ggplot2)
options(warn=1)

fig_supp_table = 'figure'
figure_number = '09'
tag = ''
location = 'onion_creek'
time_period = 'five_years'
source('mk_file_name.R')

data = WtGetEventData(location, time_period)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list(
    'NWM v1.0'=data$`NWM v1.0`,
    'NWM v1.1'=data$`NWM v1.1`,
    'NWM v1.2'=data$`NWM v1.2`),
  min_ts_length=256,
  max.scale=256,
  rm_chunks_warn=FALSE
)

we_stats = we_hydro_stats(wt_event)

figure = event_cluster_timing_summary_by_period(
    we_stats,
    wt_event=wt_event,
    n_period=3, 
    distiller_pal='Greys', 
    timing_stat='cluster_max',
    box_fill='grey90',
    signif_threshold=1 )

figure = figure$ggplot + guides(colour = FALSE)
ggsave(file=figure_name, figure)

for(tt in c(17.5, 29.5, 58.9)) {
    print(tt)
    for(vv in c('NWM v1.0', 'NWM v1.1', 'NWM v1.2')) {
        print(vv)
        print(paste0('hits: ',
            we_stats[[vv]]$xwt$event_timing$cluster_max[ abs(period - tt) < .1 ][ xwt_signif == TRUE, .(n=.N) ]$n))
        print(paste0('misses: ',
            we_stats[[vv]]$xwt$event_timing$cluster_max[ abs(period - tt) < .1 ][ xwt_signif == FALSE, .(n=.N) ]$n))
    }
}
