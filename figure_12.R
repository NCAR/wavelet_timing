options(warn=0)
options(device = png)
options(repr.plot.width = 8.5, repr.plot.height = 6, repr.plot.res=300)

library(data.table)

location <- 'taylor_river'
time_period <- 'five_years'

figure_prefix <- paste0(location,'_',time_period)
data <- WtGetEventData(location, time_period)

wt_event = WtEventTiming(
    POSIXct=data$POSIXct,
    obs=data$q_cms_obs,
    mod=list('NWM v1.2'=data$`NWM v1.2`),
    min_ts_length=800,
    max.scale=256
)

we_stats <- we_hydro_stats(wt_event)
 
# Need to save the new we_stats$obs as a different object. Could fix in github later.
we_stats_obs = we_stats
we_stats_obs$'NWM v1.2' = NULL

library(ggplot2)
library(data.table)
plot_data = list()
names(we_stats_obs$obs$wt$event_timing$streamflow_cluster_stats)
plot_data = plyr::ldply(we_stats_obs$obs$wt$event_timing[c("streamflow_cluster_stats")])
plot_data$version = 'obs'

plot_data = data.table(plot_data)
# Need to calculate max_vol, do it here.
plot_data$max_vol= plot_data$max_mean*plot_data$max_nhours*3600 # 3600 is cms to cmh
plot_data = plot_data[complete.cases(plot_data)] # Don't keep any NAs. Probably need to see why we are getting NAs here, but this is just for moment.
str(plot_data)

periods = unique(plot_data$period)
    period_facet_labeller = format(periods, digits=2, nsmall=1)
    names(period_facet_labeller) = periods
x_labeller=NULL
if(is.null(x_labeller)) {
        stat_labeller = c(
        mean_max='mean',
        max_max='max',
        `NWM v1.0`="V1.0",
        `NWM v1.1`="V1.1",
        `NWM v1.2`="V1.2",
        `NWM v2.0`="V2.0" )
    } else {
        stat_labeller = x_labeller }

# The observed WT power by period can not be obtained from we_stats. Use wt_event.
    obs_tavg = wt_event$obs$wt$event_timing$time_avg
    obs_tavg = obs_tavg[ local_max == TRUE, ]
    setkey(obs_tavg, power_corr, physical=TRUE)
    plot_data$per_fact = factor(plot_data$period, levels=rev(obs_tavg$period))
n_periods=4#NULL # This would come in w function 
if(!is.null(n_periods)) {
       n_period_use = min(n_periods, length(unique(plot_data$period)))
        plot_data = plot_data[period %in% rev(obs_tavg$period)[1:n_period_use],]
    }
signif_threshold=NULL # this would come in w function 
    if(!is.null(signif_threshold)) {
        plot_data = plot_data[xwt_signif >= signif_threshold,]
    }

bps = function(data) {
        ## The_stats = values=boxplot.stats(data)$stats
        ## These are ggplot/Tukey style
        lower = quantile(data, 0.25, na.rm=T)
        middle = median(data, na.rm=T)
        upper = quantile(data, 0.75, na.rm=T)
        iqr = upper - lower
        max_lim = upper + (1.5*iqr)
        min_lim = lower - (1.5*iqr)
        mindata = data[data > min_lim]
        ymin = if(length(mindata) & any(mindata < lower)) min(mindata, na.rm=T) else min(data)
        maxdata = data[data < max_lim]
        ymax = if(length(maxdata) && any(maxdata > upper)) max(maxdata, na.rm=T) else max(data)
        if(ymax < upper) afafafaf
        return(data.frame(ymin=ymin, lower=lower, middle=middle, upper=upper, ymax=ymax))
    }

the_keys = c('version', '.id', 'period')
    plot_stats =
        plot_data[,
                  .(
                      ymin=bps(max_max)$ymin,
                      lower=bps(max_max)$lower,
                      mean=mean(max_max),
                      middle=bps(max_max)$middle,
                      upper=bps(max_max)$upper,
                      ymax=bps(max_max)$ymax,
                      #mean_xwt_power=mean(xwt_power_corr),
                      mean_obs_power=mean(power_corr),
                      count=.N,
                      #avg_signif=mean(xwt_signif),
                      per_fact = per_fact[1]
                  ),
                  by=the_keys]

show_outliers=FALSE#TRUE # This comes in w function
if(show_outliers){
      setkeyv(plot_data, c(the_keys, 'per_fact'))
      setkeyv(plot_stats, c(the_keys, 'per_fact'))
      outliers = merge(plot_data, plot_stats)[max_max < ymin | max_max > ymax] #, .() ,by=the_keys]
    }

timing_stat = 'max_max'
show_points=FALSE
base_size=11
box_fill = 'grey80'

if(timing_stat == 'max_max') {
        the_plot =
            ggplot() +
            geom_boxplot(
                data=plot_stats,
                aes(x=per_fact,
                    #color=avg_signif,
                    #fill=avg_signif,
                    ymin=ymin, lower=lower, middle=middle, upper=upper, ymax=ymax),
                fill=box_fill,
                stat='identity') 
            ## scale_color_manual(
            ##                      name='Statistic',
            ##                      values=c(cluster_mean='grey70', cluster_max='black'),
            ##                      labels=c(cluster_mean='Cluster mean', cluster_max='Cluster max')
            ##                      )
        if(show_outliers){
         the_plot =
            the_plot +
            geom_point(data=outliers, aes(x=per_fact, y=max_max), show.legend=FALSE)
        }
    } else {
      if(show_points) {
            the_plot =
                ggplot() +
                geom_boxplot(
                    data=plot_stats,
                    aes(
                        x=version,
                        ymin=ymin, lower=lower, middle=middle, upper=upper, ymax=ymax
                    ),
                    stat='identity'
                )
        } else {
            the_plot =
                ggplot() +
                geom_boxplot(
                    data=plot_stats,
                    aes(
                        x=version,
                        ymin=ymin, lower=lower, middle=middle, upper=upper, ymax=ymax,
                        #fill=avg_signif,
                        color=avg_signif
                    ),
                    fill=box_fill,
                    stat='identity'
                )
          }
        if(show_outliers){
          the_plot =
            the_plot +
            geom_point(data=outliers, aes(x=version, y=max_max), show.legend=FALSE)
        }
    }
    if(show_points) {
        if(timing_stat == 'mean_max') {
            # THis plot is TMI, but that's just what it is.
            the_plot =
                the_plot +
                geom_label(
                    data=plot_data,
                    aes(
                        x=.id,
                        y=time_err,
                        fill=xwt_signif,
                        label=as.character(period_clusters),
                     ),
                    color='black', #.id
                    label.padding = unit(0.08, "lines"),
                    fontface="bold",
                    position='jitter',
                    size=2.5) 
        } else {
            the_plot =
                the_plot + 
                geom_label(
                    data=plot_data,
                    aes(
                        x=version,
                        y=time_err,
                        fill=xwt_signif,
                        label=as.character(period_clusters)
                    ),
                    colour="black",
                    label.padding = unit(0.08, "lines"),
                    fontface="bold",
                    position='jitter',
                    size=2.5
                ) 
        }
    }
    #the_plot =
        #the_plot +
        #facet_grid(
        #    ~ per_fact, # ~ version
        #    ##nrow=1,
        #    labeller=as_labeller(period_facet_labeller)
        #)
    if(timing_stat == 'max_max') {
      the_plot =
        the_plot +
        scale_x_discrete(name='Timescale (hr)',
                         labels=as_labeller(period_facet_labeller))
    } else {
      the_plot =
        the_plot +
        scale_x_discrete(name='Version',
                         labels=as_labeller(stat_labeller))
    }
    the_plot =
      the_plot +
        #scale_fill_distiller(name='Avg XWT\nSignif', palette=distiller_pal,
        #                     direction=distiller_direction, limits=c(0,1)) +
        #scale_color_distiller(name='Avg XWT\nSignif', palette=distiller_pal,
        #                      direction=distiller_direction, limits=c(0,1)) +
        #guides(colour = "none") + 
        scale_y_continuous(name='Max peak (cms)') +
        theme_bw(base_size=base_size)
    out_plot_stats = plot_stats
    out_plot_stats$per_fact=NULL # remove redundant col
    invisible(list(ggplot=the_plot, plot_stats=out_plot_stats))

the_plot
ggsave(
  file=paste0(figure_prefix,"_figure_max_max.png"),
  the_plot,
  height=7,
  width=7
)
