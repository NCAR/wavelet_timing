library(grid)
devtools::load_all("~/WRF_Hydro/rwrfhydro")

source_file_list = list(
  'figure_01.R',
  'figure_02.R',
  'figure_03.R',
  'figure_04.R',
  'figure_05.R',
  'figure_06.R',
  'figure_07.R',
  'figure_08.R',
  'figure_09.R',
  'figure_10.R',
  'figure_11.R',
  'figure_12.R',
  'supp_figure_02.R',
  'supp_figure_03.R',
  'supp_figure_04.R',
  'supp_figure_05.R',
  'supp_figure_06.R'
)


for(source_file in source_file_list) {
  rm(list = setdiff(ls(), c('source_file', 'source_file_list')))
  options(warn=1)
  source(source_file)
}
