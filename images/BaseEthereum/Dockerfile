FROM tomokokawase/ubuntu:16.04
MAINTAINER tomokokawase <zhanghaoyang.tomoko@bytedance.com>
ENV REFRESHED_AT 2019-02-18

# 等待配置的基础以太坊镜像

# 安装Go
# 设置环境变量，所有操作都是非交互式的
ENV DEBIAN_FRONTEND noninteractive
ENV GO_USER=golang
ENV GO_LOG_DIR=/var/log/golang

# 安装golang
RUN apt-get -yqq update && apt-get install -yqq golang

# 安装nodejs
RUN apt-get -qq update && apt-get install -yqq curl sudo
RUN apt-get -qq install -y nodejs npm
RUN npm config set registry https://registry.npm.taobao.org
RUN apt install -y nodejs-legacy && npm install n -g
RUN sudo n stable

# 安装geth
RUN apt-get -yqq install software-properties-common
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN apt-get -yqq update
RUN apt-get -yqq install ethereum

# 安装solc编译器
RUN npm install -g solc

# 安装git和web3.js
RUN apt-get install -yqq git
RUN npm install -g yarn
RUN yarn add global web3 