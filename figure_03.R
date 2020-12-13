
fig_supp_table = 'figure'
figure_number = '03'
tag = 'synthetic'
location = 'onion_creek'
time_period = 'one_event'
source('mk_file_name.R')

data = WtGetEventData(location, time_period)

offsetIt = 5 # hours
offstart = rep(NA, times = offsetIt)
pairStart = 1
pairEnd   = dim(data)[1] - offsetIt
offend = data$q_cms_obs[pairStart:pairEnd]
data$q_cms_obs_off = c(offstart, offend)

wt_event = WtEventTiming(
  POSIXct=data$POSIXct,
  obs=data$q_cms_obs,
  mod=list('Synthetic'=data$`q_cms_obs_off`),
  min_ts_length=24,
  max.scale=256,
  rm_chunks_warn=FALSE
)

figure <- step2_figure(wt_event, ylab_spacer=.08)
ggsave(file=figure_name, figure)
