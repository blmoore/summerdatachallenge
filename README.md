<p align="center">
<img src="writeup/images/logo3_hires.png" /><br />
<img src="writeup/images/logotext.png" width="200" />
</p>

This repo containts my entry for Imperial create lab's [summerdatachallenge](http://summerdatachallenge.com). The challenge was to apply data science techniques to one or more of their supplied datasets. I chose **London house prices**, listings for all house sales within 100 km of the City of London from 2009 up to 2014.

A short written report can be found under [`report/sdc_report.pdf`](report/sdc_report.pdf) and there's an accompanying site at [blm.io/datarea](http://blm.io/datarea).

## How to run

The competition data is **not** included in this repository due to its terms of use. Therefore to run these scripts, place the file `Houseprice_2009_100km_London.csv` (137 MB) in directory `houseprices/` — then each Rscript can be run as standalone using: `Rscript <scriptname>`

## sessionInfo()

Below is the output of `sessionInfo()` which shows loaded package versions, the OS and R version (3.1.1) under which these scripts were written.

```
R version 3.1.1 (2014-07-10)
Platform: x86_64-apple-darwin13.1.0 (64-bit)

locale:
[1] en_GB.UTF-8/en_GB.UTF-8/en_GB.UTF-8/C/en_GB.UTF-8/en_GB.UTF-8

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] rgeos_0.3-6      maptools_0.8-30  mapdata_2.2-3    maps_2.3-9       gpclib_1.5-5    
 [6] gridExtra_0.9.1  ggplot2_1.0.0    forecast_5.6     timeDate_3010.98 zoo_1.7-11      
[11] dplyr_0.3.0.2    sp_1.0-15       

loaded via a namespace (and not attached):
 [1] assertthat_0.1   codetools_0.2-9  colorspace_1.2-4 DBI_0.3.1        digest_0.6.4    
 [6] foreign_0.8-61   fracdiff_1.4-2   gtable_0.1.2     lattice_0.20-29  magrittr_1.0.1  
[11] MASS_7.3-35      munsell_0.4.2    nnet_7.3-8       parallel_3.1.1   plyr_1.8.1      
[16] proto_0.3-10     quadprog_1.5-5   rCharts_0.4.5    Rcpp_0.11.3      reshape2_1.4    
[21] RJSONIO_1.3-0    scales_0.2.4     stringr_0.6.2    tools_3.1.1      tseries_0.10-32 
[26] whisker_0.3-2    yaml_2.1.13 
```
