library(rwrfhydro)
library(data.table)
library(ggplot2)

fig_supp_table = 'figure'
figure_number = '08'
tag = ''
location = 'taylor_river'
time_period = 'one_season'
source('mk_file_name.R')

data = WtGetEventData(location, time_period)

setnames(data, 'q_cms_obs', 'obs')

measure_vars = c('obs', 'NWM v1.2')
plot_data = melt(data, id.vars=c('POSIXct'), measure.vars=measure_vars)
streamflow_colors = RColorBrewer::brewer.pal('Paired', n=3)[1:2]
names(streamflow_colors) = rev(unique(plot_data$variable))
plot_data$variable = factor(plot_data$variable, levels=rev(measure_vars))
      
figure =
  ggplot(plot_data) +
  geom_line(aes(x=POSIXct, y=value, color=variable), size=1.5) +
  scale_color_manual(values=streamflow_colors, name=NULL) +
  scale_y_log10(name='Streamflow (cms)') +
  scale_x_datetime(name=NULL, date_labels="%d %h\n%Y") + 
  theme_bw()

ggsave(file=figure_name, figure)
