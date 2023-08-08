# local-appstore-for-1Panel

> [1Panel本地应用商店 / local appstore for 1Panel](https://github.com/xxxily/local-appstore-for-1Panel/blob/main/local_appstore_sync_helper.sh)

## 特性

- 可一键更新同步1Panel官网的应用商店应用到本地环境
- 支持将任意第三方仓库的应用同步到1Panel的本地应用商店
- 支持github，gitlab，gitee等公开仓库、私有仓库
- 支持将多个分散的仓库应用同步到1Panel的本地应用商店
- 支持自定义拉取的分支、克隆深度、访问代理等，方便灵活
- 同步脚本源码完全开源，可自行修改、扩展，可放心使用

## 使用场景

- 1Panel官方应用商店的应用更新慢，想要快速更新到本地进行使用
- 1Panel官方应用有BUG，或者版本太低，想要自己修改后使用
- 1Panel官方应用商店没有自己想要的应用，想要自己添加应用
- 由于某些原因没法上架到1Panel官方应用商店，定制自己的专属应用
- 用于快速调试开发1Panel应用，方便本地开发调试
- 想要将多个分散的仓库应用同步到1Panel的本地应用商店

## 效果演示

将1Panel appstore里最近更的应用一键同步到本地应用商店

![read_cron_task_result](https://raw.githubusercontent.com/xxxily/local-appstore-for-1Panel/main/docs/img/read_cron_task_result.png)

## 使用教程

### 1. 使用1Panel创建计划任务

![new_cron_task](https://raw.githubusercontent.com/xxxily/local-appstore-for-1Panel/main/docs/img/new_cron_task.png)

按上图方式创建计划任务。  

然后将 [local_appstore_sync_helper.sh](https://github.com/xxxily/local-appstore-for-1Panel/blob/main/local_appstore_sync_helper.sh) 内容复制到脚本内容框中。  

按需修改脚本中的配置项，具体的配置项说明见下文。

### 2. 执行同步脚本

点击执行按钮，可即可开始同步。

![run_cron_task](https://raw.githubusercontent.com/xxxily/local-appstore-for-1Panel/main/docs/img/run_cron_task.png)

### 3. 查看同步脚本的执行情况

点击任务名称或【报告】按钮即可查看同步脚本的执行日志。

![run_cron_task_result](https://raw.githubusercontent.com/xxxily/local-appstore-for-1Panel/main/docs/img/run_cron_task_result.png)

注意：目前1Panel的计划任务执行失败的话查看不了任何日志，这个时候去【主机】>【文件】然后进入：  

`/opt/1panel_hepler/logs`  

目录下查看同步脚本的执行日志即可。

### 4. 查看同步成功的本地应用

进入【应用商店】点击右上角的【更新应用列表】即可查看同步到的本地应用。

![read_cron_task_result](https://raw.githubusercontent.com/xxxily/local-appstore-for-1Panel/main/docs/img/read_cron_task_result.png)

## 配置项详解

[local_appstore_sync_helper.sh](https://github.com/xxxily/local-appstore-for-1Panel/blob/main/local_appstore_sync_helper.sh) 里包含了一些配置项，可以根据自己的需求进行修改。

```bash
# 1panel本地app的目录（如果不是默认安装，需修改该目录）
app_local_dir="/opt/1panel/resource/apps/local"

# AppStore的git仓库地址（必选）
git_repo_url="https://github.com/xxxily/local-appstore-for-1Panel"
# git_repo_url="https://github.com/1Panel-dev/appstore"

# 访问git仓库的access token，访问私有仓库时用，优先级高于账密（可选）
# 建议使用access token，降低账密泄露的风险
git_access_token=""

# 访问git仓库的用户名，访问私有仓库时用（可选）
git_username=""
# 访问git仓库的密码，访问私有仓库时用（可选）
git_password=""

# 指定克隆的分支（可选）
git_branch=""
# 指定克隆的深度（可选）
git_depth=1

# 拉取远程仓库前是否清空本地app目录（可选）
clean_local_app=false
# 拉取远程仓库前是否清空远程app缓存（可选）
clean_remote_app_cache=false

# 设置克隆或拉取远程仓库时使用的代理（可选）
proxyUrl=""
# 设置示例：
# proxyUrl="http://127.0.0.1:7890"
# proxyUrl="socks5://127.0.0.1:7890"
# proxyUrl="socks5://user:password@host:port"

# 将远程app store工程克隆到本地的工作目录
work_dir="/opt/1panel_hepler"
```

各个配置项的具体说明如下：

| 配置项 | 必选 | 使用说明 |
| ---: | :---: | :--- |
| app_local_dir | 是 | 1Panel本地app的目录（如果不是默认安装，需修改该目录） |
| git_repo_url | 是 | AppStore的git仓库地址，直接复制链接地址即可，脚本会自动补充链接需要的字段 |
| git_access_token | 否 | 访问git仓库的access token，访问私有仓库时用，优先级高于账密 |
| git_username | 否 | 访问git仓库的用户名，访问私有仓库时用 |
| git_password | 否 | 访问git仓库的密码，访问私有仓库时用；脚本已增加了对特殊字符的支持 |
| git_branch | 否 | 指定克隆的分支，不指定则使用仓库的默认分支 |
| git_depth | 否 | 指定克隆的深度，层级越多克隆越慢，建议默认即可 |
| clean_local_app | 否 | 拉取远程仓库前是否清空本地app目录，可以把不需要旧应用清除掉，保持跟线上的一致<br />如果要同步多个仓库的应用，则必须设定为`flase`，否则只会看到最后一个的同步结果 |
| clean_remote_app_cache | 否 | 拉取远程仓库前是否清空远程app缓存，相当于重新clone远程app仓库 |
| proxyUrl | 否 | 设置克隆或拉取远程仓库时使用的代理，一般来说国内克隆GitHub仓的时候用得到 |
| work_dir | 是 | 将远程app store工程克隆到本地的工作目录，用于临时存放克隆下来的文件和脚本工作日志 |

## 1Panel应用源

| 应用源 | 地址 | 说明 |
| --- | --- | --- |
| 1Panel-appstore | [https://github.com/1Panel-dev/appstore](https://github.com/1Panel-dev/appstore) | 1Panel官方应用商店 |
| okxlin-appstore | [https://github.com/okxlin/appstore](https://github.com/okxlin/appstore) | 基于1Panel的第三方应用商店 |
| local-appstore-for-1Panel | [https://github.com/xxxily/local-appstore-for-1Panel](https://github.com/xxxily/local-appstore-for-1Panel) | 集成linuxserver的1Panel的第三方应用商店（待集成） |

## 相关链接

- [1Panel](https://github.com/1Panel-dev/1Panel)
- [1Panel-appstore](https://github.com/1Panel-dev/appstore)
