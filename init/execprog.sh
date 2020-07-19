#!/system/bin/sh

exec > /dev/kmsg 2>&1

if [ -f /sbin/recovery ]; then
  exit
fi

while ! cat /vendor/bin/init.qcom.post_boot.sh 2>&1 | grep -q /sys/devices/system/cpu; do sleep 1; done

if mount | grep -q /vendor/etc/msm_irqbalance.conf; then
  rm "$0"
  exit 0
fi

# Replace msm_irqbalance.conf
echo "PRIO=1,1,0,0
# arch_timer,arch_mem_timer,MDSS,408000.qcom,cpu-bwmon,arm-pmu,kgsl-3d0
IGNORED_IRQ=27,62,115,215,23,332" > /dev/msm_irqbalance.conf
chmod 644 /dev/msm_irqbalance.conf
mount --bind /dev/msm_irqbalance.conf /vendor/etc/msm_irqbalance.conf
chcon "u:object_r:vendor_configs_file:s0" /vendor/etc/msm_irqbalance.conf

# Append to post_boot
cat /vendor/bin/init.qcom.post_boot.sh > /dev/post_boot
echo '
# Setup readahead
find /sys/devices -name read_ahead_kb | while read node; do echo 128 > $node; done

killall msm_irqbalance
sleep 1
start vendor.msm_irqbalance' >> /dev/post_boot
chmod 755 /dev/post_boot
mount --bind /dev/post_boot /vendor/bin/init.qcom.post_boot.sh
chcon "u:object_r:qti_init_shell_exec:s0" /vendor/bin/init.qcom.post_boot.sh

rm "$0"
exit 0
