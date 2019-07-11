# utils

This repository contains various stuffs that otherwise would be lost on my computer. Mostly not useful unless you asked for them.


## pre-commit hook

After placing [this script](https://github.com/mvaudel/utils/blob/master/hooks/pre-commit) in your _.git/hooks_ folder, your files will be checked for standard mistakes prior to commit. This avoids cross-compatiblity issues and commiting very large files.


## Transfer speed

[This R script](https://github.com/mvaudel/utils/blob/master/src/dl_speed/test_hunt.R) takes output from `sftp` and plots the reported transfer speed. Note that the [sftp output](https://github.com/mvaudel/utils/blob/master/docs/dl_speed/log.txt) is a dirty copy-paste of the terminal with manual clean-up.

- Speed vs. Size

![](https://github.com/mvaudel/utils/blob/master/docs/dl_speed/speed_size.png)

- Size

![](https://github.com/mvaudel/utils/blob/master/docs/dl_speed/size.png)



