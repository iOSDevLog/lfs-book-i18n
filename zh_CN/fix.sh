#!/bin/sh

# fix some English and ASCII specific stuff which can not be handled by po4a

# This should be handled by po4a, but if some pages are not done yet
# we will need to do it manually.
sed -e '/encoding=/s|ISO-8859-1|UTF-8|' -i $(find -name \*.xml)

# Let tidy output UTF-8
sed -e '/output-encoding:/s|latin1|utf8|' -i tidy.conf

# Remove two seds causing encoding error in UTF-8
sed -e '/xa9/d' -i Makefile

sed -e 's|<book>|<book lang="zh_cn">|' -i index.xml

sed -e '/xreflabel/s|Chapter.nbsp.1 - Mailing Lists|第 1 章 - 邮件列表|' \
	-e '/xreflabel/s|Chapter.nbsp.1 - Mirror sites|第 1 章 - 镜像站|'    \
	-i chapter01/resources.xml

sed -e '/xreflabel/s|Chapter.nbsp.\([0-9]\+\)|第 \1 章|' \
	-i chapter*/chapter*.xml

sed -e '/xreflabel/s|Host System Requirements|宿主系统需求|' \
	-i chapter02/hostreqs.xml

sed -e '/xreflabel/s|General Compilation Instructions|通用编译说明|' \
	-i part3intro/generalinstructions.xml

sed -e '/xreflabel/s|Toolchain Technical Notes|工具链技术说明|' \
	-i part3intro/toolchaintechnotes.xml

sed -e '/xreflabel/s|Package build instructions|软件包构建说明|' \
	-i part3intro/generalinstructions.xml

sed -e '/xreflabel/s|"gcc-pass1"|"第一遍的 GCC"|' \
	-i chapter05/gcc-pass1.xml

sed -e '/xreflabel/s|Appendix|附录|' -i \
	appendices/acknowledgments.xml      \
	appendices/acronymlist.xml          \
	appendices/dependencies.xml         \
	appendices/license.xml              \
	appendices/scripts.xml              \
	appendices/udev-rules.xml

sed -e 's/Approximate build time/估计构建时间/'               \
	-e 's/Required disk space/需要硬盘空间/'                  \
	-e 's/Installation depends on/安装依赖于/'                \
	-e 's/Test suite depends on/测试依赖于/'                  \
	-e 's/Must be installed before/必须在下列软件包之前安装/' \
	-e 's/Optional dependencies/可选依赖项/'                  \
	-i  general.ent

reldate=$(grep 'releasedate' general.ent |
	      sed 's/.*"\(.*\)".*/\1/;s/st\|nd\|rd\|th//');
if reldate_cn=$(LANG=zh_CN.UTF-8 \
                date -d "$reldate" "+%Y 年 %b %d 日" \
                2>/dev/null); then
	reldate_cn=$(echo "$reldate_cn" | sed 's/月/ &/')
	sed "/releasedate/s/\".*\"/\"${reldate_cn}\"/" -i general.ent
fi

# Some buggy comments produced by po4a are adding extra empty lines.
# Remove them.
sed -e '/<screen.*><!--/,+1N;s/<!--.*-->\n//' -i \
	chapter02/hostreqs.xml                       \
	chapter06/ncurses.xml

# Apply lfs-l10n.xml patch, if it's not applied
grep "Simplified Chinese" stylesheets/lfs-xsl/lfs-l10n.xml ||
	patch -N -p1 -i ../patches/lfs-l10n.xml.patch
