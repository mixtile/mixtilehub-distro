FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://wired.network \
"

do_install_append() {
  install -d ${D}${sysconfdir}/systemd/network
  install -m 0644 ${WORKDIR}/wired.network ${D}${sysconfdir}/systemd/network/
}
