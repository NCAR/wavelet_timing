fig_supp_table = 'figure'
figure_number = '06'
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

## Add the cluster max to the figure
## This could be added to the above function.
we_stats = we_hydro_stats(wt_event)
maxs = we_stats$`NWM v1.2`$xwt$event_timing$cluster_max
maxs$period_str = as.character(maxs$period)
maxs$period_factor = factor(maxs$period)
maxs = maxs[period_str %in% figure$data$per_str]

clust_numbers = unique(sort(maxs$period_clusters))
clust_fill_colors = c(NA, rwrfhydro:::cluster_palette()(length(clust_numbers)))
names(clust_fill_colors) = c('None', clust_numbers)

ff = figure +
    geom_vline(
        data=maxs,
        size=.5,
        key_glyph = "path",
        aes(xintercept=time_err,
            linetype=xwt_signif, #'Cluster Maximum',
            color=as.factor(period_clusters))) + 
            # alpha=xwt_signif)) +
    scale_color_manual(
        values=clust_fill_colors,
        name='Event Cluster Number',
        na.translate=TRUE)  +
    scale_linetype_manual(
        ## values=c('Cluster Maximum'=1),
        values=c('TRUE'=1, 'FALSE'=2),
        ## name='')
        labels=c('TRUE'='Hit', 'FALSE'='Miss'),
        name='Cluster Max Event') +
    guides(
        fill = guide_legend(order = 1),
        alpha = guide_legend(order = 2),        
        linetype = guide_legend(order = 3),
        color=FALSE)

ggsave(file=figure_name, figure)
