#!/bin/bash

# 这个脚本的作用是从不同的仓库中克隆openwrt相关的代码，并进行一些处理

# 定义一个函数，用来克隆指定的仓库和分支
clone_repo() {
  # 参数1是仓库地址，参数2是分支名，参数3是目标目录
  repo_url=$1
  branch_name=$2
  target_dir=$3
  # 克隆仓库到目标目录，并指定分支名和深度为1
  git clone -b $branch_name --depth 1 $repo_url $target_dir
}

# 定义一些变量，存储仓库地址和分支名
latest_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][5-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
openwrt_repo="https://github.com/openwrt/openwrt.git"

# 开始克隆仓库，并行执行
clone_repo $openwrt_repo $latest_release openwrt &
# 等待所有后台任务完成
wait

# fanchmwrt处理
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/inittab ./openwrt/target/linux/x86/base-files/etc/inittab
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/sysupgrade.conf ./openwrt/package/base-files/files/etc/sysupgrade.conf
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/950-fwx-nf-conn-struct-user-hook.patch ./openwrt/target/linux/generic/hack-6.12/
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/target.mk ./openwrt/include/target.mk
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/fwx.meta ./openwrt/package/base-files/files/etc/
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/login.sh ./openwrt/package/base-files/files/usr/libexec/login.sh
cp -f $GITHUB_WORKSPACE/FILES/fcmfiles/Makefile ./openwrt/package/base-files/Makefile
cp -rf $GITHUB_WORKSPACE/FILES/fcmfiles/fcm ./openwrt/package/
sed -i "s/hostname='OpenWrt'/hostname='FanchmWrt'/g" ./openwrt/package/base-files/files/bin/config_generate
sed -i "s/timezone='GMT0'/timezone='HKT-8'/g" ./openwrt/package/base-files/files/bin/config_generate
sed -i "s/zonename='UTC'/zonename='Asia\/Hong Kong'/g" ./openwrt/package/base-files/files/bin/config_generate
sed -i "s/default "OpenWrt"/default "FanchmWrt"/g" ./openwrt/package/base-files/image-config.in

# 进行一些处理
cp -f $GITHUB_WORKSPACE/FILES/feeds.conf.default ./openwrt/feeds.conf.default
cp -f $GITHUB_WORKSPACE/FILES/menu-fanchmwrt.js ./openwrt/package/fcm/luci-theme-fanchmwrt/htdocs/luci-static/resources/menu-fanchmwrt.js
cp -rf $GITHUB_WORKSPACE/FILES/fanchmwrt/* ./openwrt/package/fcm/luci-theme-fanchmwrt/htdocs/luci-static/fanchmwrt/

# 退出脚本
exit 0
