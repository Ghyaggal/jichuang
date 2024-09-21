# 基于Arm Cortex-M0的视频处理系统
基于安路科技的EG4S20上构建Cortex-M0片上微处理器子系统.   
   
基于Arm Cortex-M0处理器在限定的FPGA平台上构建ISP（image signal process）片上系统，完成对原始视频信号的图像处理功能。此 SoC 上，需要从 SD 卡读取原始视频数据，原始视频数据由企业提供，然后进入到ISP 硬件加速模块进行视频信号处理（图像处理算法不限），处理后通过VGA 或者 HDMI 接口显示在显示屏上。