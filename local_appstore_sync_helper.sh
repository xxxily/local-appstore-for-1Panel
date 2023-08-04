#!/bin/bash

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

# 将远程app store工程克隆到本地的工作目录
work_dir="/opt/1panel_hepler"

set -e

mkdir -p "$work_dir/logs"
log_file="$work_dir/logs/local_appstore_sync_helper_$(date +"%Y-%m-%d").log"
logs() {
  local message="$1"

  if [ -n "$log_file" ]; then
    mkdir -p "$(dirname "$log_file")"
    if [ $? -eq 0 ]; then
      echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message"
      echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message" >>"$log_file"
      return
    fi
  fi

  echo "$message"
}

# 函数: url_encode
# 参数:
#   - url: 需要进行编码的字符串
# 返回值:
#   经过URL编码后的字符串
function url_encode() {
  local string=$1
  local length="${#string}"
  local url_encoded_string=""
  local c

  for ((i = 0; i < length; i++)); do
    c=${string:i:1}
    case "$c" in
    [a-zA-Z0-9.~_-]) url_encoded_string+=$c ;;
    *) url_encoded_string+=$(printf '%%%02X' "'$c") ;;
    esac
  done

  echo "$url_encoded_string"
}

# 定义函数，接收一个URL参数和可选的替换字符串参数
replace_protocol() {
  local url=$1
  local replacement=$2

  # 如果没有提供替换字符串，则删除"http://"或"https://"
  if [[ -z $replacement ]]; then
    local new_url=$(echo $url | sed "s/http:\/\///" | sed "s/https:\/\///")
  else
    local new_url=$(echo $url | sed "s/http:\/\//${replacement}/" | sed "s/https:\/\//${replacement}/")
  fi

  # 输出替换后的URL
  echo $new_url
}

# 函数: clone_git_repo
# 参数:
#   - url: Git仓库URL
#   - username: 账号（可选）
#   - password: 密码（可选）
#   - access_token: 访问令牌（可选）
#   - branch: 克隆分支（可选）
#   - depth: 克隆深度（可选，默认为0，即克隆整个仓库）
function clone_git_repo() {
  local url=$1
  local username=$2
  local password=$3
  local access_token=$4
  local branch=$5
  local depth=$6

  branch=${branch:+--branch $branch}
  depth=${depth:+--depth $depth}

  echo "branch: $branch, depth: $depth"

  if [[ -n $access_token ]]; then
    echo "use access_token to clone"
    local fix_url=$(replace_protocol "$url")
    git clone "https://oauth2:$access_token@$fix_url" $branch $depth
  elif [[ -n $username && -n $password ]]; then
    local encoded_username=$(url_encode "$username")
    local encoded_password=$(url_encode "$password")
    local fix_url=$(replace_protocol "$url")

    # echo "use username and password to clone, encoded_username: $encoded_username, encoded_password: $encoded_password, fix_url: $fix_url"
    echo "use username and password to clone"

    git clone "https://$encoded_username:$encoded_password@$fix_url" $branch $depth
  else
    echo "use default clone"
    git clone "$url" $branch $depth
  fi
}

function scriptInfo() {
  echo ""
  logs "##################################################################"
  logs "#    Name: local appstore sync helper for 1Panel                 #"
  logs "# Version: v1.0.0                                                #"
  logs "#  Author: xxxily                                                #"
  logs "#  Github: https://github.com/xxxily/local-appstore-for-1Panel   #"
  logs "##################################################################"
  echo ""
}

function main() {
  scriptInfo

  if [ ! -d "$app_local_dir" ]; then
    logs "未检测到1panel的app目录，请检查1panel是否安装正确，或修改脚本中的app_local_dir变量"
    exit 1
  fi

  # 检查地址结尾是否包含.git，如果不包含则自动补全
  if [[ "$git_repo_url" != *".git" ]]; then
    git_repo_url="${git_repo_url}.git"
  fi

  local repo_username=""
  local repo_projectname=""

  # 使用正则表达式匹配仓库地址中的用户名和项目名
  if [[ $git_repo_url =~ .*\/(.*)\/(.*)\.git ]]; then
    repo_username=${BASH_REMATCH[1]}
    repo_projectname=${BASH_REMATCH[2]}
    # logs "用户名: $repo_username"
    # logs "项目名: $repo_projectname"
  fi

  if [ -z "$repo_username" ] || [ -z "$repo_projectname" ]; then
    logs "无法提取用户名和项目名，请检查git_repo_url变量提供的地址是否正确"
    exit 1
  fi

  mkdir -p "$work_dir/temp"

  local repo_user_dir="$work_dir/temp/$repo_username"
  local repo_dir="$repo_user_dir/$repo_projectname"

  # 根据clean_remote_app_cache变量的值决定是否清空远程app的缓存数据
  if [ "$clean_remote_app_cache" = true ] && [ -d "$repo_dir" ]; then
    rm -rf "$repo_dir"
    logs "已清空远程app的缓存数据"
  fi

  # clone或拉取远程仓库最新代码
  logs "准备获取远程仓库最新代码：$git_repo_url"
  if [ -d "$repo_dir" ]; then
    logs "执行git pull操作"
    cd "$repo_dir"

    # 强行拉取最新代码
    git pull --force 2>>"$log_file"
  else
    logs "执行git clone操作"
    mkdir -p "$repo_user_dir"
    cd "$repo_user_dir"

    clone_git_repo "$git_repo_url" "$git_username" "$git_password" "$git_access_token" "$git_branch" "$git_depth" 2>>"$log_file"
  fi

  logs "远程仓库最新代码获取完成"

  if [ ! -d "$repo_dir/apps" ]; then
    logs "未检测到apps目录，请检查远程仓库是否正确"
    exit 1
  fi

  # 根据clean_local_app变量的值决定是否清空本地app目录
  if [ "$clean_local_app" = true ]; then
    rm -rf "$app_local_dir"/*
    logs "已清空本地原有的app"
  fi

  # 将远程仓库的apps目录下的所有app复制到本地app_local_dir目录下
  cd "$repo_dir"
  cp -rf apps/* "$app_local_dir"

  pwd
  ls -lah
  du -sh

  # 根据clean_remote_app_cache变量的值决定是否清空远程app的缓存数据
  if [ "$clean_remote_app_cache" = true ]; then
    rm -rf "$repo_dir"
  fi

  logs "1panel本地app同步成功，enjoy it!"
}

main "$@"
