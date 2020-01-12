## Test environments
* local Windows 10 install, R 3.6.0
* ubuntu 16.0.4.2 LTS, R 3.6.0
* win builder devel and release
## R CMD check results
* 0 errors v | 0 warnings v | 0 notes
## Downstream dependencies
None
## Updates to remedy submission failure
* Readme now links to full URI
* R.E email question about citations in the description field, geoviz doesn't apply any published methods
## Changes summary from 0.2.1
* 'Rayshader' changing coordinate system in v0.13.1 caused GPS tracks to be offset. latlong_to_rayshader_coords() updated to fix
* Updated mosaic_files() example to prevent build note
